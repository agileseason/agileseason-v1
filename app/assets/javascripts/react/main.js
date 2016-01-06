$(document).on('page:change', function () {
  if (document.body.id != 'boards_show') {
    return;
  }

  // TODO Extract to other file.
  Number.prototype.pad = function(size) {
    var s = String(this);
    while (s.length < (size || 2)) { s = "0" + s; }
    return s;
  }

  var React = require('react');
  var ReactDOM = require('react-dom');

  window.IssueModal = React.createClass({
    getInitialState: function() {
      return {
        issue: this.props.issue,
        currentLabels: this.getCheckedLabels(),
        currentAssignee: this.getAssignedUser(),
        currentDueDate: this.props.issue.dueDate,
        comments: []
      };
    },
    issueUrl: function() {
      return '/boards/agileseason/test_dev/issues/' + this.props.issue.number;
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
      var checkedLabels = []
      this.props.issue.labels.forEach(function(label) {
        if (label.checked) {
          checkedLabels.push(label);
        }
      });
      return checkedLabels;
    },
    getAssignedUser: function() {
      var assignee = null;
      this.props.issue.collaborators.forEach(function(user) {
        if (user.assigned) {
          assignee = user;
        }
      });
      return assignee;
    },
    updateIssueMiniature: function(number, html) {
      $('#issues_' + number).replaceWith(html);
    },
    componentDidMount: function() {
      this.request(this.issueUrl(), 'GET', {}, function(issue) {
        this.setState({ issue: issue });
      });
      this.loadCommentFromServer();
    },
    handleCloseButton: function() {
      $('.issue-modal-container').hide();
    },
    handleLabelChange: function(labelName, checked) {
      var labelsToSave = []
      this.props.issue.labels.forEach(function(label) {
        if (label.name == labelName) {
          label.checked = checked;
        }
        if (label.checked) {
          labelsToSave.push(label.name);
        }
      });
      this.setState({ currentLabels: this.getCheckedLabels() })

      var url = this.issueUrl() + '/update_labels';
      this.request(url, 'PATCH', { issue: { labels : labelsToSave } }, function(data) {
        this.updateIssueMiniature(data.number, data.issue);
      });
    },
    handleAssigneeChange: function(login, assigned) {
      this.props.issue.collaborators.forEach(function(user) {
        if (user.login == login) {
          user.assigned = assigned;
        } else {
          user.assigned = false;
        }
      });
      this.setState({ currentAssignee: this.getAssignedUser() })

      var url = this.issueUrl() + '/assignee/' + login;
      this.request(url, 'GET', {}, function(data) {
        this.updateIssueMiniature(data.number, data.issue);
      });
    },
    handleCommentSubmit: function(comment, successCallback) {
      var url = this.issueUrl() + '/comment';
      this.request(url, 'POST', { comment: comment }, function(data) {
        successCallback();
        comments = this.state.comments
        comments.push(data.comment)
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
        successCallback(comment);
      });
    },
    handleDueDateChange: function(date, time) {
      var url = this.issueUrl() + '/due_date';
      var datetime = null;
      var currentDueDate = null;

      if (date != null) {
        datetime = date + ' ' + time;
        currentDueDate = new Date(datetime + ' UTC');
      }

      this.setState({currentDueDate: currentDueDate});
      this.request(url, 'POST', { due_date: datetime }, function(data) {
        this.updateIssueMiniature(data.number, data.issue);
      });
    },
    bodyMarkdown: function() {
      return {__html: this.state.issue.bodyMarkdown};
    },
    render: function() {
      var githubIssueUrl = 'https://github.com/' + this.props.github_full_name + '/issues/' + this.props.issue.number;
      return (
        <div className='issueModal'>
          <div className='issue-content'>
            <h1>
              {this.state.issue.title} <a href={githubIssueUrl}>#{this.state.issue.number}</a>
              <CurrentDueDate data={this.state.currentDueDate} />
            </h1>
            <CloseButton onButtonClick={this.handleCloseButton} />
            <CurrentLabelList data={this.state.currentLabels} />
            <div className='move-to'>
              <CurrentAssignee user={this.state.currentAssignee} />
            </div>
            <div className='issue-body' dangerouslySetInnerHTML={this.bodyMarkdown()} />

            <CommentList data={this.state.comments} onDeleteClick={this.handleDeleteComment} onUpdateClick={this.handleUpdateComment} />
            <CommentForm onCommentSubmit={this.handleCommentSubmit} />
          </div>
          <div className='issue-actions'>
            <LabelList data={this.props.issue.labels} onLabelChange={this.handleLabelChange} />
            <AssigneeList data={this.props.issue.collaborators} onAssigneeChange={this.handleAssigneeChange} />
            <DueDateAction date={this.props.issue.dueDate} onDueDateChange={this.handleDueDateChange} />
          </div>
        </div>
      );
    }
  });

  var CurrentDueDate = React.createClass({
    getDate: function() {
      var res = '';
      if (this.props.data) {
        var date = new Date(this.props.data);
        var yearStr = (new Date()).getUTCFullYear() == date.getUTCFullYear() ? '' : '.' + date.getUTCFullYear();
        res = (date.getUTCDate()).pad() + '.' + (date.getUTCMonth() + 1).pad() + yearStr
          + ' ' + (date.getUTCHours()).pad() + ':' + (date.getUTCMinutes()).pad();
      }
      return res;
    },
    render: function() {
      if (this.props.data) {
        return <div className='current-due-date' title='Due Date'>{this.getDate()}</div>;
      } else {
        return <span />
      }
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
          <li style={{ backgroundColor: label.color }} key={label.name}>{label.name}</li>
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
      return (<div className='close' onClick={this.handleClick}></div>)
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
    // TODO Remove this function
    getAssignedUser: function() {
      var assignee = null;
      this.props.data.forEach(function(user) {
        if (user.assigned) {
          assignee = user;
        }
      });
      return assignee;
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
        return (
          <Assignee key={user.login} avatarUrl={user.avatarUrl} assigned={user.assigned} onAssigneeChange={this.props.onAssigneeChange}>
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
    getInitialState: function() {
      return { assigned: this.props.assigned }
    },
    handleChange: function() {
      this.setState({ assigned: this.refs.assigneeCheckbox.checked });
      this.props.onAssigneeChange(this.props.children, this.refs.assigneeCheckbox.checked);
    },
    render: function() {
      return (
        <div className='assign'>
          <input
            type='checkbox'
            checked={this.props.assigned}
            ref='assigneeCheckbox'
            onChange={this.handleChange}
          />
          <span>{this.props.children}</span>
        </div>
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
          <Label key={label.id} color={label.color} checked={label.checked} onLabelChange={this.props.onLabelChange}>
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
      return { checked: this.props.checked }
    },
    handleChange: function() {
      this.setState({ checked: this.refs.labelCheckbox.checked });
      this.props.onLabelChange(this.props.children, this.refs.labelCheckbox.checked);
    },
    render: function() {
      return (
        <div className='label' style={{backgroundColor: this.props.color}}>
          <input
            type='checkbox'
            checked={this.state.checked}
            ref='labelCheckbox'
            onChange={this.handleChange}
          />
          <span>{this.props.children}</span>
        </div>
      );
    }
  });

  var EditButton = React.createClass({
    handleClick: function() {
      return this.props.onButtonClick();
    },
    buttonClass: function() {
      return this.props.name.replace(/\s/g, '-').toLowerCase() + ' issue-button'
    },
    render: function() {
      return (
        <div className={this.buttonClass()} onClick={this.handleClick}>
          <span className={this.props.icon}></span>
          <span>{this.props.name}</span>
        </div>
      );
    }
  });

  var PopoverOverlay = React.createClass({
    handleClick: function() {
      return this.props.onOverlayClick();
    },
    render: function() {
      return (
        <div className='popup-overlay' style={{display: this.props.display}} onClick={this.handleClick}></div>
      );
    }
  });

  var Avatar = React.createClass({
    render: function() {
      return (
        <img
          className='avatar'
          src={this.props.data.avatar_url}
          title={this.props.data.login}
          height={this.props.height}
          width={this.props.width}
        />
      );
    }
  });

  var CommentList = React.createClass({
    render: function() {
      var commentNodes = this.props.data.map(function(comment) {
        return (
          <Comment
            data={comment}
            key={comment.id}
            onDeleteClick={this.props.onDeleteClick}
            onUpdateClick={this.props.onUpdateClick}
          />
        );
      }.bind(this));
      return (
        <div className="comment-list">
          {commentNodes}
        </div>
      );
    }
  });

  var Comment = React.createClass({
    getInitialState: function() {
      return {
        bodyDisplay: 'block',
        formDisplay: 'none',
        body: this.props.data.body,
        bodyMarkdown: this.props.data.bodyMarkdown,
        currentClass: 'comment',
        opacity: 1.0
      };
    },
    handleEditClick: function() {
      this.setState({
        bodyDisplay: 'none',
        formDisplay: 'block',
        currentClass: 'comment editable'
      });
    },
    handleCloseWithoutSaveClick: function() {
      this.setState({
        bodyDisplay: 'block',
        formDisplay: 'none',
        body: this.state.body,
        currentClass: 'comment'
      });
    },
    handleCommentSubmit: function(comment) {
      this.props.onUpdateClick(this.props.data.id, comment, this.updateCommentFinish);
      this.setState({ body: comment.body, opacity: 0.5 });
    },
    handleDeleteClick: function() {
      if (confirm('Are you sure?')) {
        this.props.onDeleteClick(this.props.data.id);
      }
    },
    updateCommentFinish: function(comment) {
      this.setState({
        bodyDisplay: 'block',
        formDisplay: 'none',
        currentClass: 'comment',
        bodyMarkdown: comment.bodyMarkdown,
        opacity: 1.0
      });
    },
    bodyMarkdown: function() {
      return {__html: this.state.bodyMarkdown};
    },
    render: function() {
      return (
        <div className={this.state.currentClass} style={{backgroundColor: this.state.backgroundColor}}>
          <Avatar data={this.props.data.user} width={40} height={40} />
          <div className='header'>
            <div className='login'>{this.props.data.user.login}</div>
            <div className='date'>{this.props.data.created_at}</div>
            &nbsp;&mdash;&nbsp;
            <a href='#' onClick={this.handleEditClick}>edit</a>
            &nbsp;or&nbsp;
            <a href='#' onClick={this.handleDeleteClick}>delete</a>
          </div>
          <div className='body' style={{display: this.state.bodyDisplay}}>
            <div dangerouslySetInnerHTML={this.bodyMarkdown()} />
          </div>
          <CommentEditForm
            data={this.props.data}
            display={this.state.formDisplay}
            body={this.state.body}
            onCloseWithoutSaveClick={this.handleCloseWithoutSaveClick}
            onCommentSubmit={this.handleCommentSubmit}
            opacity={this.state.opacity}
          />
        </div>
      );
    }
  });

  var CommentEditForm = React.createClass({
    getInitialState: function() {
      return {
        body: this.props.body,
        diaplay: this.props.display
      };
    },
    handleTextChange: function(e) {
      this.setState({ body: e.target.value });
    },
    handleSubmit: function(e) {
      e.preventDefault();
      this.saveComment();
    },
    componentDidMount: function() {
      // TODO Remove copy-past $textarea
      var textarea = $('#' + this.props.data.id)
      textarea.on('keydown', function(e) {
        if (e.keyCode == 13 && (e.metaKey || e.ctrlKey)) {
          this.saveComment();
          return false;
        }
      }.bind(this));
    },
    componentDidUpdate: function() {
      var textarea = $('#' + this.props.data.id)
      if (!textarea.hasClass('elasticable')) {
        textarea.addClass('elasticable');
        textarea.elastic();
        textarea.focus().val('').val(this.state.body);
      }
    },
    saveComment: function() {
      var body = this.state.body.trim();
      if (!body) {
        return;
      }
      var textarea = $('#' + this.props.data.id)
      textarea.blur();
      this.props.onCommentSubmit({body: body});
    },
    render: function() {
      return (
        <form className='comment-edit-form' onSubmit={this.handleSubmit} style={{display: this.props.display}}>
          <textarea
            id={this.props.data.id}
            type='text'
            placeholder='Edit comment or upload an image...'
            value={this.state.body}
            onChange={this.handleTextChange}
            style={{opacity: this.props.opacity}}
          />
          <div className='actions'>
            <a href='#' onClick={this.props.onCloseWithoutSaveClick}>Close without save</a>
            <input type='submit' value='Update' className='button' />
          </div>
        </form>
      );
    }
  });

  var CommentForm = React.createClass({
    getInitialState: function() {
      return { body: '', opacity: 1.0 };
    },
    handleTextChange: function(e) {
      this.setState({body: e.target.value});
    },
    handleSubmit: function(e) {
      e.preventDefault();
      this.saveCommentBegin();
    },
    componentDidMount: function() {
      this.textarea().elastic();
      this.textarea().on('keydown', function(e) {
        if (e.keyCode == 13 && (e.metaKey || e.ctrlKey)) {
          this.saveCommentBegin();
          return false;
        }
      }.bind(this));
    },
    textarea: function() {
      return $('.comment-form textarea');
    },
    saveCommentBegin: function() {
      var body = this.state.body.trim();
      if (!body) {
        return;
      }
      this.setState({opacity: 0.5});
      this.textarea().blur();
      this.props.onCommentSubmit({body: body}, this.saveCommentFinish);
    },
    saveCommentFinish: function() {
      this.setState({body: '', opacity: 1.0});
    },
    render: function() {
      return (
        <form className='comment-form' onSubmit={this.handleSubmit}>
          <textarea
            type='text'
            placeholder='Add new comment or upload an image...'
            value={this.state.body}
            onChange={this.handleTextChange}
            style={{opacity: this.state.opacity}}
          />
          <div className='actions'>
            <input type='submit' value='Comment' className='button' />
          </div>
        </form>
      );
    }
  });

  window.IssueModalRender = function(issue, github_full_name) {
    ReactDOM.render(
      <IssueModal
        issue={issue}
        github_full_name={github_full_name}
      />,
      document.getElementById('issue-modal')
    );
  }

});
