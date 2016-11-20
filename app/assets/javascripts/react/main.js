$(document).on('turbolinks:load', function () {
  if (!/boards_show|age_index|control_index|cumulative_index|frequency_index|lines_index/.test(document.body.id)) {
    return;
  }

  // Close Issue modals by click on container shadow
  $('.issue-modal-container').on('click', function(e) {
    var $target = $(e.target);
    if ($target.is('.issue-modal-container')) {
      $('.close-modal', $target).trigger('click');
      return false;
    }
  });

  // Fixed action buttons on scroll down.
  $('.issue-modal-container').on('scroll', function(e) {
    $('.issue-actions').toggleClass('fixed', $(e.target).scrollTop() >= 138);
  })

  var React = require('react');
  var ReactDOM = require('react-dom');
  var CloseButton = require('./close-button.jsx');
  var Title = require('./title.jsx');
  var ColumnList = require('./column-list.jsx');
  var CommentList = require('./comment-list.jsx');
  var Label = require('./label.jsx');
  var UploadForm = require('./upload-form.jsx');
  var PopoverOverlay = require('./popover.jsx');
  var ColorPicker = require('./color-picker.jsx');
  var IssueModalNew = require('./modal-new.jsx');

  window.IssueModalNewRender = function(labels, submitUrl, columnId) {
    ReactDOM.render(
      <IssueModalNew
        labels={labels}
        submitUrl={submitUrl}
        columnId={columnId}
      />,
      document.getElementById('issue-modal-new')
    );
  }

  window.IssueModal = React.createClass({
    getInitialState: function() {
      return {
        issue: this.props.issue,
        collaborators: this.props.issue.collaborators,
        currentLabels: this.getCheckedLabels(),
        currentAssignee: this.props.issue.assignee,
        currentDueDate: this.props.issue.dueDate,
        currentState: this.props.issue.state,
        currentColor: this.props.issue.color,
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
    fetchIssueMiniature: function() {
      var url = this.issueUrl() + '/miniature';
      this.request(url, 'GET', {}, function(data) {
        this.updateIssueMiniature(data.number, data.issue);
      });
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
      window.RemoveNumberFromUrl();
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

      var url = this.issueUrl() + '/labels';
      var params = { issue: { labels : labelsToSave } };
      this.request(url, 'PATCH', params, function(data) {
        this.updateIssueMiniature(data.number, data.issue);
      });
    },
    handleAssigneeChange: function(user, isAssigned) {
      var assignee = isAssigned ? user : null;
      this.setState({ currentAssignee: assignee });

      var url = this.issueUrl() + '/assignee/' + user.login;
      this.request(url, 'PATCH', {}, function(data) {
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
        setTimeout(function() { this.fetchIssueMiniature(); }.bind(this), 1000);
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
    handleColorChange: function(color) {
      this.setState({currentColor: color});
      var url = this.issueUrl() + '/colors';
      var params = { issue: { color : color } };
      this.request(url, 'PATCH', params, function(data) {
        this.updateIssueMiniature(data.number, data.issue);
      });
    },
    handleColumnChange: function(columnId) {
      var url = this.issueUrl() + '/moves/' + columnId + '/force';
      this.request(url, 'PATCH', {}, function(data) {
        for (var badge in data.badges) {
          window.update_wip_column(badge);
        }
      });
    },
    handleStateButtonClick: function(state) {
      this.setState({currentState: state});
      var url = this.issueUrl() + '/states'
      this.request(url, 'PATCH', { state: state }, function(data) {
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
    setColor: function(color) {
      $('.issue-modal').css('background-color', color);
    },
    bodyMarkdown: function() {
      return {__html: this.state.issue.bodyMarkdown};
    },
    modalClassName: function() {
      return 'issueModal ' + this.state.currentState;
    },
    render: function() {
      this.setColor(this.state.currentColor);
      var githubIssueUrl = 'https://github.com/' + this.props.githubFullName +
        '/issues/' + this.props.issue.number;
      return (
        <div className={this.modalClassName()}>
          <div className='issue-content'>
            <Title
              number={this.props.issue.number}
              title={this.props.issue.title}
              url={githubIssueUrl}
              state={this.state.currentState}
              dueDate={this.state.currentDueDate}
              isReadonly={this.props.isReadonly}
              onUpdateTitle={this.handleUpdateTitle}
            />
            <CloseButton onButtonClick={this.handleCloseButton} />
            <CurrentLabelList data={this.state.currentLabels} />
            <div className='move-to'>
              <CurrentAssignee user={this.state.currentAssignee} />
              <ColumnList
                current={this.state.issue.columnId}
                data={this.state.issue.columns}
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
            <ColorPickerAction onColorChange={this.handleColorChange} />
            <ToggleButton name='Ready' isChecked={this.state.issue.isReady} onButtonClick={this.handleReadyButtonClick} icon='octicon octicon-check' title='Mark the issue with the "ready to next stage" label' />
            <EditButton name='Close Issue' options='close' onButtonClick={this.handleStateButtonClick} icon='octicon octicon-issue-closed' />
            <EditButton name='Reopen Issue' options='reopen' onButtonClick={this.handleStateButtonClick} icon='octicon octicon-issue-reopened' />
            <EditButton name='Archive Issue' options='archive' onButtonClick={this.handleStateButtonClick} icon='octicon octicon-package' title='Remove the issue from board' />
            <EditButton name='Send to Board' options='unarchive' onButtonClick={this.handleStateButtonClick} icon='octicon octicon-package' title='Send the issue to board' />
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
            <a className='save' href='#' data-turbolinks='false' onClick={this.handleSaveClick}>Save Date & Time</a>
            <a className='remove' href='#' data-turbolinks='false' onClick={this.handleRemoveClick}>Remove</a>
          </div>
        </div>
      );
    }
  });

  var ColorPickerAction = React.createClass({
    getInitialState: function() {
      return {
        overlay: 'none'
      };
    },
    handleColorOnChange: function(color, name) {
      this.handleEditButtonClick();
      this.props.onColorChange(color, name);
    },
    handleEditButtonClick: function() {
      if (this.state.overlay == 'none') {
        overlay = 'block';
      } else {
        overlay = 'none';
      }
      this.setState({overlay: overlay});
    },
    render: function() {
      return (
        <div>
          <EditButton
            name='Color'
            onButtonClick={this.handleEditButtonClick}
            icon='octicon octicon-paintcan'
          />
          <PopoverOverlay
            display={this.state.overlay}
            onOverlayClick={this.handleEditButtonClick}
          />
          <ColorPicker
            display={this.state.overlay}
            onColorChange={this.handleColorOnChange}
          />
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
        <a className='assign' href='#' data-turbolinks='false' onClick={this.handleChange}>
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
      setTimeout(function() {
        if (!$textarea.hasClass('elasticable')) {
          $textarea.addClass('elasticable');
          $textarea.elastic();
        }
      }.bind(this), 10);

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
      if (this.state.opacity == 1.0) {
        this.setState({ body: this.state.body + imageUrl + "\n" });
        this.focusToEnd();
      }
    },
    handleSubmit: function(e) {
      e.preventDefault();
      if (this.state.opacity == 1.0) {
        this.saveCommentBegin();
      }
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
      var buttonText = this.state.opacity == 1.0 ? 'Comment' : 'Comment...';
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
              <input type='submit' value={buttonText} className='button' />
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
    window.AddNumberToUrl(issue.number, issue.title);
  }
});

window.AddNumberToUrl = function(number, title) {
  var issueUrl = window.location.href.replace(/#|\?.*/g, '') + '?number=' + number;
  window.history.pushState({}, title, issueUrl);
}

window.RemoveNumberFromUrl = function() {
  var boardUrl = window.location.href.replace(/#|\?.*/g, '')
  window.history.pushState({}, '', boardUrl);
}
