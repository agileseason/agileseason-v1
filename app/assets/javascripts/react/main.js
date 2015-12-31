$(document).on('page:change', function () {
  if (document.body.id != 'boards_show') {
    return;
  }

  var React = require('react');
  var ReactDOM = require('react-dom');

  window.IssueModal = React.createClass({
    getInitialState: function() {
      return {
        issue: this.props.issue,
        currentLabels: this.getCheckedLabels(),
        currentAssignee: this.getAssignedUser(),
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
    handleCommentSubmit: function(comment) {
      var url = this.issueUrl() + '/comment';
      this.request(url, 'POST', { comment: comment}, function(comment) {
        comments = this.state.comments
        comments.push(comment)
        this.setState({ comments: comments });
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
    render: function() {
      var githubIssueUrl = 'https://github.com/' + this.props.github_full_name + '/issues/' + this.props.issue.number;
      return (
        <div className='issueModal'>
          <h1>{this.state.issue.title} <a href={githubIssueUrl}>#{this.state.issue.number}</a></h1>
          <CurrentLabelList data={this.state.currentLabels} />
          <CloseButton onButtonClick={this.handleCloseButton} />
          <CurrentAssignee user={this.state.currentAssignee} />

          <div className='issue-actions'>
            <LabelList data={this.props.issue.labels} onLabelChange={this.handleLabelChange} />
            <AssigneeList data={this.props.issue.collaborators} onAssigneeChange={this.handleAssigneeChange} />
          </div>

          <CommentList data={this.state.comments} onDeleteClick={this.handleDeleteComment} />
          <CommentForm onCommentSubmit={this.handleCommentSubmit} />
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
    render: function() {
      return (
        <div className={this.props.name.toLowerCase()} onClick={this.handleClick}>
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
          <Comment data={comment} key={comment.id} onDeleteClick={this.props.onDeleteClick} />
        );
      }.bind(this));
      return (
        <div className="comment-list">
          {commentNodes}
        </div>
      );
    }
  });

  var DeleteComment = React.createClass({
    handleClick: function() {
      if (confirm('Are you sure?')) {
        this.props.onDeleteClick(this.props.id);
      }
    },
    render: function() {
      return (
        <a href='#' onClick={this.handleClick}>delete</a>
      );
    }
  });

  var Comment = React.createClass({
    render: function() {
      return (
        <div className='comment'>
          <Avatar data={this.props.data.user} width={40} height={40} />
          <div className='header'>
            <div className='login'>{this.props.data.user.login}</div>
            <div className='date'>{this.props.data.created_at}</div>
            &nbsp;&mdash;&nbsp;
            <a href='#edit'>edit</a>
            &nbsp;or&nbsp;
            <DeleteComment id={this.props.data.id} onDeleteClick={this.props.onDeleteClick} />
          </div>
          <div className='body'>{this.props.data.body}</div>
        </div>
      );
    }
  });

  var CommentForm = React.createClass({
    getInitialState: function() {
      return { body: '' };
    },
    handleTextChange: function(e) {
      this.setState({body: e.target.value});
    },
    handleSubmit: function(e) {
      e.preventDefault();
      this.saveComment();
    },
    componentDidMount: function() {
      var textarea = $('.comment-form textarea')
      textarea.elastic();
      textarea.on('keydown', function(e) {
        if (e.keyCode == 13 && (e.metaKey || e.ctrlKey)) {
          this.saveComment();
          return false;
        }
      }.bind(this));
    },
    saveComment: function() {
      var body = this.state.body.trim();
      if (!body) {
        return;
      }
      this.props.onCommentSubmit({ body: body });
      this.setState({ body: '' });
    },
    render: function() {
      return (
        <form className='comment-form' onSubmit={this.handleSubmit}>
          <textarea
            type='text'
            placeholder='Add new comment or upload an image...'
            value={this.state.body}
            onChange={this.handleTextChange}
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
