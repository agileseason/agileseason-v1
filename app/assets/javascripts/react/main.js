$(document).on('page:change', function () {
  if (document.body.id != 'boards_show') {
    return;
  }

  // TODO Extract to other file.
  Number.prototype.pad = function(size) {
    var s = String(this);
    while (s.length < (size || 2)) { s = '0' + s; }
    return s;
  };

  var React = require('react');
  var ReactDOM = require('react-dom');
  var Title = require('./title.jsx');
  var ColumnList = require('./column-list.jsx');
  var CommentList = require('./comment-list.jsx');
  var UploadForm = require('./upload-form.jsx');
  var PopoverOverlay = require('./popover.jsx');

  window.IssueModal = React.createClass({
    getInitialState: function() {
      return {
        issue: this.props.issue,
        collaborators: this.props.issue.collaborators,
        currentLabels: this.getCheckedLabels(),
        currentAssignee: this.props.issue.assignee,
        currentDueDate: this.props.issue.dueDate,
        currentState: this.props.issue.state,
        comments: this.getStubComments(this.props.issue.commentCount)
      };
    },
    issueUrl: function() {
      return '/boards/' + this.props.githubFullName + '/issues/' +
        this.props.issue.number;
    },
    request: function(url, type, data, successFunc) {
      $.ajax({
        url: url,
        dataType: 'json',
        type: type,
        data: data,
        cache: false,
        success: successFunc.bind(this),
        error: function(xhr, status, err) {
          console.error(url, status, err.toString());
        }.bind(this)
      });
    },
    loadCommentFromServer: function() {
      var url = this.issueUrl() + '/comments';
      this.request(url, 'GET', {}, function(data) {
        this.setState({ comments: data.comments });
      });
    },
    getCheckedLabels: function() {
      var checkedLabels = [];
      this.props.issue.labels.forEach(function(label) {
        if (label.checked) {
          checkedLabels.push(label);
        }
      });
      return checkedLabels;
    },
    getStubComments: function(count) {
      var stubs = [];
      for (var i=0; i<count; i++) {
        stubs.push({id: i, isStub: true});
      }

      return stubs;
    },
    updateIssueMiniature: function(number, html) {
      $('#issues_' + number).replaceWith(html);
    },
    componentDidMount: function() {
      this.request(this.issueUrl(), 'GET', {}, function(issue) {
        this.setState({ issue: issue });
        this.setState({ currentAssignee: issue.assignee });
      });
      this.loadCommentFromServer();
    },
    handleCloseButton: function() {
      $('.issue-modal-container').hide();
    },
    handleUpdateTitle: function(title) {
      var url = this.issueUrl() + '/update';
      this.request(url, 'PATCH', { issue: { title : title } }, function(data) {
        this.updateIssueMiniature(data.number, data.issue);
      });
    },
    handleLabelChange: function(labelName, checked) {
      var labelsToSave = [];
      this.props.issue.labels.forEach(function(label) {
        if (label.name == labelName) {
          label.checked = checked;
        }
        if (label.checked) {
          labelsToSave.push(label.name);
        }
      });
      this.setState({ currentLabels: this.getCheckedLabels() });

      var url = this.issueUrl() + '/update_labels';
      var params = { issue: { labels : labelsToSave } };
      this.request(url, 'PATCH', params, function(data) {
        this.updateIssueMiniature(data.number, data.issue);
      });
    },
    handleAssigneeChange: function(user, isAssigned) {
      var assignee = isAssigned ? user : null;
      this.setState({ currentAssignee: assignee });

      var url = this.issueUrl() + '/assignee/' + user.login;
      this.request(url, 'GET', {}, function(data) {
        this.updateIssueMiniature(data.number, data.issue);
      });
    },
    handleCommentSubmit: function(comment, successCallback) {
      var url = this.issueUrl() + '/comment';
      this.request(url, 'POST', { comment: comment }, function(data) {
        successCallback();
        comments = this.state.comments;
        comments.push(data.comment);
        this.setState({ comments: comments });
        this.updateIssueMiniature(data.board_issue.number, data.board_issue.issue);
      });
    },
    handleDeleteComment: function(id) {
      var url = this.issueUrl() + '/delete_comment/' + id;
      this.request(url, 'DELETE', {}, function(data) {
        this.updateIssueMiniature(data.number, data.issue);
      });
      var comments = [];
      this.state.comments.forEach(function(comment) {
        if (comment.id != id) {
          comments.push(comment);
        }
      });
      this.setState({ comments: comments });
    },
    handleUpdateComment: function(id, comment, successCallback) {
      var url = this.issueUrl() + '/update_comment/' + id;
      this.request(url, 'POST', { comment: comment }, function(comment) {
        if (successCallback) {
          successCallback(comment);
        }
      });
    },
    handleDueDateChange: function(date, time) {
      var url = this.issueUrl() + '/due_date';
      var datetime = null;
      var currentDueDate = null;

      if (date !== null) {
        datetime = date + ' ' + time;
        currentDueDate = new Date(datetime + ' UTC');
      }

      this.setState({currentDueDate: currentDueDate});
      this.request(url, 'POST', { due_date: datetime }, function(data) {
        this.updateIssueMiniature(data.number, data.issue);
      });
    },
    handleColumnChange: function(columnId) {
      var url = this.issueUrl() + '/move_to/' + columnId + '/force';
      this.request(url, 'GET', {}, function(data) {
        // TODO Update column badges.
      });
    },
    handleStateButtonClick: function(state) {
      this.setState({currentState: state});
      var url = this.issueUrl() + '/' + state;
      this.request(url, 'GET', {}, function(data) {
        if (state == 'archive') {
          $('#issues_' + data.number).remove();
        } else {
          this.updateIssueMiniature(data.number, data.issue);
        }
      });
    },
    handleReadyButtonClick: function(state) {
      var url = this.issueUrl() + '/toggle_ready';
      this.state.issue.isReady = state;
      this.setState({issue: this.state.issue});
      this.request(url, 'POST', {}, function(data) {
        this.updateIssueMiniature(data.number, data.issue);
      });
    },
    bodyMarkdown: function() {
      return {__html: this.state.issue.bodyMarkdown};
    },
    modalClassName: function() {
      return 'issueModal ' + this.state.currentState;
    },
    render: function() {
      var githubIssueUrl = 'https://github.com/' + this.props.githubFullName +
        '/issues/' + this.props.issue.number;
      return (
        <div className={this.modalClassName()}>
          <div className='issue-content'>
            <Title
              number={this.props.issue.number}
              title={this.props.issue.title}
              url={githubIssueUrl}
              dueDate={this.state.currentDueDate}
              isReadonly={this.props.isReadonly}
              onUpdateTitle={this.handleUpdateTitle}
            />
            <CloseButton onButtonClick={this.handleCloseButton} />
            <CurrentLabelList data={this.state.currentLabels} />
            <div className='move-to'>
              <CurrentAssignee user={this.state.currentAssignee} />
              <ColumnList
                data={this.state.issue.columns}
                current={this.state.issue.columnId}
                isReadonly={this.props.isReadonly}
                onColumnChange={this.handleColumnChange}
              />
            </div>
            <div className='issue-body' dangerouslySetInnerHTML={this.bodyMarkdown()} />

            <CommentList
              data={this.state.comments}
              onDeleteClick={this.handleDeleteComment}
              onUpdateClick={this.handleUpdateComment}
            />
            <CommentForm onCommentSubmit={this.handleCommentSubmit} />
          </div>
          <div className='issue-actions'>
            <LabelList data={this.props.issue.labels} onLabelChange={this.handleLabelChange} />
            <AssigneeList
              data={this.props.issue.collaborators}
              current={this.state.currentAssignee}
              onAssigneeChange={this.handleAssigneeChange}
            />
            <DueDateAction date={this.state.issue.dueDate} onDueDateChange={this.handleDueDateChange} />
            <EditButton name='Close Issue' options='close' onButtonClick={this.handleStateButtonClick} icon='octicon octicon-issue-closed' />
            <EditButton name='Reopen Issue' options='reopen' onButtonClick={this.handleStateButtonClick} icon='octicon octicon-issue-reopened' />
            <EditButton name='Archive Issue' options='archive' onButtonClick={this.handleStateButtonClick} icon='octicon octicon-package' title='Remove the issue from board' />
            <EditButton name='Send to Board' options='unarchive' onButtonClick={this.handleStateButtonClick} icon='octicon octicon-package' title='Send the issue to board' />
            <ToggleButton name='Ready' isChecked={this.state.issue.isReady} onButtonClick={this.handleReadyButtonClick} icon='octicon octicon-check' title='Mark the issue with the "ready to next stage" label' />
          </div>
        </div>
      );
    }
  });

  var CurrentAssignee = React.createClass({
    render: function() {
      if (this.props.user) {
        return (<img className='current-assignee' src={this.props.user.avatarUrl} title={this.props.user.login} />);
      } else {
        return (<div className='current-assignee' />);
      }
    }
  });

  var CurrentLabelList = React.createClass({
    render: function() {
      var labelNodes = this.props.data.map(function(label) {
        return (
          <li
            style={{ backgroundColor: label.backgroundColor, color: label.color }}
            key={label.name}>
            {label.name}
          </li>
        );
      }.bind(this));
      return (
        <ul className='current-label-list'>{labelNodes}</ul>
      );
    }
  });

  var CloseButton = React.createClass({
    handleClick: function(e) {
      e.preventDefault();
      this.props.onButtonClick();
    },
    render: function() {
      return (<div className='close-modal' onClick={this.handleClick}></div>)
    }
  });

  var DueDateAction = React.createClass({
    getInitialState: function() {
      var date = new Date();
      var time = '12:00'
      if (this.props.date) {
        date = new Date(this.props.date);
        time = (date.getUTCHours()).pad() + ':' + (date.getUTCMinutes()).pad();
      }
      return {
        date: this.props.date,
        datepickerDate: date,
        datepickerTime: time,
        overlay: 'none'
      };
    },
    componentDidMount: function() {
      var $datepicker = $(this.refs.datepicker)
      $datepicker.datepicker({dateFormat: 'yy/mm/dd'});
      $datepicker.datepicker('setDate', this.state.datepickerDate)
    },
    handleTimeOnChange: function() {
      this.setState({datepickerTime: this.refs.time.value});
    },
    handleEditButtonClick: function() {
      $('.due-date-calendar').toggleClass('hidden');
      state = { overlay: 'block' };
      if ($('.due-date-calendar').hasClass('hidden')) {
        state = { overlay: 'none'};
      }
      this.setState(state);
    },
    handleSaveClick: function() {
      this.props.onDueDateChange(this.refs.datepicker.value, this.refs.time.value);
      this.handleEditButtonClick();
    },
    handleRemoveClick: function() {
      this.props.onDueDateChange(null, null);
      this.handleEditButtonClick();
    },
    render: function() {
      return (
        <div>
          <EditButton name='Due Date' onButtonClick={this.handleEditButtonClick} icon='octicon octicon-clock' />
          <PopoverOverlay display={this.state.overlay} onOverlayClick={this.handleEditButtonClick} />
          <div className='due-date-calendar hidden'>
            <div className='datepicker' ref='datepicker'/>
            <input className='time' ref='time' value={this.state.datepickerTime} onChange={this.handleTimeOnChange} placeholder='hh:mm' />
            <a className='save' href='#' onClick={this.handleSaveClick}>Save Date & Time</a>
            <a className='remove' href='#' onClick={this.handleRemoveClick}>Remove</a>
          </div>
        </div>
      );
    }
  });

  var AssigneeList = React.createClass({
    getInitialState: function() {
      return { data: this.props.data, overlay: 'none' };
    },
    handleEditButtonClick: function() {
      $('.assignee-list').toggleClass('hidden');
      state = { overlay: 'block' };
      if ($('.assignee-list').hasClass('hidden')) {
        state = { overlay: 'none'};
      }
      this.setState(state);
    },
    render: function() {
      var assigneeNodes = this.state.data.map(function(user) {
        var isAssigned = this.props.current && this.props.current.login == user.login;
        return (
          <Assignee
            key={user.login}
            user={user}
            assigned={isAssigned}
            onAssigneeChange={this.props.onAssigneeChange}
          >
            {user.login}
          </Assignee>
        );
      }.bind(this));
      return (
        <div>
          <EditButton name='Assignee' onButtonClick={this.handleEditButtonClick} icon='octicon octicon-person' />
          <PopoverOverlay display={this.state.overlay} onOverlayClick={this.handleEditButtonClick} />
          <div className='assignee-list hidden'>
            {assigneeNodes}
          </div>
        </div>
      );
    }
  });

  var Assignee = React.createClass({
    handleChange: function() {
      this.props.onAssigneeChange(
        this.props.user,
        !this.props.assigned
      );
    },
    render: function() {
      var checkedClass = this.props.assigned ? 'octicon octicon-check' : '';
      return (
        <a className='assign' href='#' onClick={this.handleChange}>
          <img src={this.props.user.avatarUrl} title={this.props.user.login} />
          <span>{this.props.children}</span>
          <span className={checkedClass}></span>
        </a>
      );
    }
  });

  var LabelList = React.createClass({
    getInitialState: function() {
      return { data: this.props.data, labelOverlay: 'none' };
    },
    handleEditButtonClick: function() {
      $('.label-list').toggleClass('hidden');
      if ($('.label-list').hasClass('hidden')) {
        this.setState({labelOverlay: 'none'});
      } else {
        this.setState({labelOverlay: 'block'});
      }
    },
    render: function() {
      var labelNodes = this.props.data.map(function(label) {
        return (
          <Label key={label.id} data={label} onLabelChange={this.props.onLabelChange}>
            {label.name}
          </Label>
        );
      }.bind(this));
      return (
        <div>
          <EditButton name='Labels' onButtonClick={this.handleEditButtonClick} icon='octicon octicon-tag' />
          <PopoverOverlay display={this.state.labelOverlay} onOverlayClick={this.handleEditButtonClick} />
          <div className='label-list hidden'>
            {labelNodes}
          </div>
        </div>
      );
    }
  });

  var Label = React.createClass({
    getInitialState: function() {
      return { checked: this.props.data.checked }
    },
    handleChange: function() {
      this.setState({ checked: this.refs.labelCheckbox.checked });
      this.props.onLabelChange(this.props.children, this.refs.labelCheckbox.checked);
    },
    render: function() {
      return (
        <label
          className='label'
          style={{backgroundColor: this.props.data.backgroundColor, color: this.props.data.color}}>
          <input
            type='checkbox'
            checked={this.state.checked}
            ref='labelCheckbox'
            onChange={this.handleChange}
          />
          {this.props.children}
        </label>
      );
    }
  });

  var EditButton = React.createClass({
    handleClick: function() {
      return this.props.onButtonClick(this.props.options);
    },
    buttonClass: function() {
      return this.props.name.replace(/\s/g, '-').toLowerCase() + ' issue-button'
    },
    render: function() {
      return (
        <div className={this.buttonClass()} onClick={this.handleClick} title={this.props.title}>
          <span className={this.props.icon}></span>
          <span>{this.props.name}</span>
        </div>
      );
    }
  });

  var ToggleButton = React.createClass({
    handleClick: function() {
      return this.props.onButtonClick(!this.props.isChecked);
    },
    buttonClass: function() {
      var activeClass = this.props.isChecked ? 'active' : '';
      return this.props.name.replace(/\s/g, '-').toLowerCase()
        + ' issue-button '
        + activeClass;
    },
    render: function() {
      return (
        <div className={this.buttonClass()} onClick={this.handleClick} title={this.props.title}>
          <span className={this.props.icon}></span>
          <span>{this.props.name}</span>
        </div>
      );
    }
  });

  var CommentForm = React.createClass({
    getInitialState: function() {
      return { body: '', opacity: 1.0 };
    },
    componentDidMount: function() {
      var $textarea = $(this.refs.textarea);
      $textarea.elastic();
      $textarea.on('keydown', function(e) {
        if (e.keyCode == 13 && (e.metaKey || e.ctrlKey)) {
          this.saveCommentBegin();
          return false;
        }
      }.bind(this));
    },
    handleTextChange: function(e) {
      this.setState({body: e.target.value});
    },
    focusToEnd: function() {
      $(this.refs.textarea).focus().val('').val(this.state.body);
    },
    handleUpload: function(imageUrl) {
      this.setState({ body: this.state.body + imageUrl + "\n" });
      this.focusToEnd();
    },
    handleSubmit: function(e) {
      e.preventDefault();
      this.saveCommentBegin();
    },
    saveCommentBegin: function() {
      var body = this.state.body.trim();
      if (!body) {
        return;
      }
      this.setState({opacity: 0.5});
      $(this.refs.textarea).blur();
      this.props.onCommentSubmit({body: body}, this.saveCommentFinish);
    },
    saveCommentFinish: function() {
      this.setState({body: '', opacity: 1.0});
    },
    render: function() {
      return (
        <div className='comment-form'>
          <form onSubmit={this.handleSubmit}>
            <textarea
              ref='textarea'
              type='text'
              placeholder='Leave a comment or upload an image...'
              value={this.state.body}
              onChange={this.handleTextChange}
              style={{opacity: this.state.opacity}}
            />
            <div className='actions'>
              <input type='submit' value='Comment' className='button' />
            </div>
          </form>
          <UploadForm onUpload={this.handleUpload} />
        </div>
      );
    }
  });

  window.IssueModalRender = function(issue, githubFullName, isReadonly) {
    ReactDOM.render(
      <IssueModal
        issue={issue}
        githubFullName={githubFullName}
        isReadonly={isReadonly}
      />,
      document.getElementById('issue-modal')
    );
  }
});
