$(document).on('page:change', function () {
  if (document.body.id != 'boards_show') {
    return;
  }

  var React = require('react');
  var ReactDOM = require('react-dom');

  window.IssueModal = React.createClass({
    getInitialState: function() {
      return {
        issue: {
          number: this.props.number,
          title: '...'
        },
        // TODO Move currentLabels to issue.
        currentLabels: this.getCheckedLabels(),
        comments: []
      };
    },
    issueUrl: function() {
      return '/boards/agileseason/test_dev/issues/' + this.props.number;
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
          console.error(this.props.url, status, err.toString());
        }.bind(this)
      });
    },
    loadCommentFromServer: function() {
      var url = this.issueUrl() + '/comments';
      this.request(url, 'GET', {}, function(comments) {
        this.setState({ comments: comments });
      });
    },
    getCheckedLabels: function() {
      var checkedLabels = []
      this.props.labels.forEach(function(label) {
        if (label.checked) {
          checkedLabels.push(label);
        }
      });
      return checkedLabels;
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
      this.props.labels.forEach(function(label) {
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
    handleCommentSubmit: function(comment) {
      var url = this.issueUrl() + '/comment';
      this.request(url, 'POST', { comment: comment}, function(comment) {
        comments = this.state.comments
        comments.push(comment)
        this.setState({ comments: comments });
      });
    },
    render: function() {
      var githubIssueUrl = 'https://github.com/' + this.props.github_full_name + '/issues/' + this.props.number;
      return (
        <div className='issueModal'>
          <h1>{this.state.issue.title} <a href={githubIssueUrl}>#{this.state.issue.number}</a></h1>
          <CurrentLabelList data={this.state.currentLabels} />
          <CloseButton onButtonClick={this.handleCloseButton} />
          <div className='actions'>
            <LabelList data={this.props.labels} onLabelChange={this.handleLabelChange} />
          </div>

          <CommentList data={this.state.comments} />
          <CommentForm onCommentSubmit={this.handleCommentSubmit} />
        </div>
      );
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
        <div className="label" style={{backgroundColor: this.props.color}}>
          <input
            type="checkbox"
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

  var CommentList = React.createClass({
    getInitialState: function() {
      return { data: this.props.data };
    },
    render: function() {
      var commentNodes = this.props.data.map(function(comment) {
        return (
          // TODO Remove user as array
          <Comment author={comment.user[0][1]} key={comment.id}>
            {comment.body}
          </Comment>
        );
      });
      return (
        <div className="commentList">
          {commentNodes}
        </div>
      );
    }
  });

  var Comment = React.createClass({
    render: function() {
      return (
        <div className="comment">
          <h3 className="commentAuthor">
            {this.props.author}
          </h3>
          {this.props.children}
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
      var body = this.state.body.trim();
      if (!body) {
        return;
      }
      this.props.onCommentSubmit({body: body});
      this.setState({body: ''});
    },
    render: function() {
      return (
        <form className="commentForm" onSubmit={this.handleSubmit}>
          <input
            type='text'
            placeholder='Add new comment or upload an image...'
            value={this.state.body}
            onChange={this.handleTextChange}
          />
          <input type='submit' value='Post' />
        </form>
      );
    }
  });

  window.IssueModalRender = function(number, labels, github_full_name) {
    ReactDOM.render(
      <IssueModal
        number={number}
        labels={labels}
        github_full_name={github_full_name}
      />,
      document.getElementById('issue-modal')
    );
  }

});