$(document).on('page:change', function () {
  if (document.body.id != 'boards_show') {
    return;
  }

  var React = require('react');
  var ReactDOM = require('react-dom');

  window.IssueModal = React.createClass({
    issueUrl: function() {
      return '/boards/agileseason/test_dev/issues/' + this.props.number;
    },
    getInitialState: function() {
      return { issue: { number: this.props.number, title: '...' }, comments: [] };
    },
    loadCommentFromServer: function() {
      var url = this.issueUrl() + '/comments';
      $.ajax({
        url: url,
        dataType: 'json',
        cache: false,
        success: function(comments) {
          this.setState({ comments: comments });
        }.bind(this),
        error: function(xhr, status, err) {
          console.error(this.props.url, status, err.toString());
        }.bind(this)
      });
    },
    componentDidMount: function() {
      $.ajax({
        url: this.issueUrl(),
        dataType: 'json',
        cache: false,
        success: function(issue) {
          this.setState({ issue: issue });
        }.bind(this),
        error: function(xhr, status, err) {
          console.error(this.issueUrl(), status, err.toString());
        }.bind(this)
      });
      this.loadCommentFromServer();
    },
    handleCloseButton: function() {
      $('.issue-modal-container').hide();
    },
    handleCommentSubmit: function(comment) {
      $.ajax({
        url: this.issueUrl() + '/comment',
        dataType: 'json',
        type: 'POST',
        data: { 'comment': comment},
        success: function(comment) {
          comments = this.state.comments
          comments.push(comment)
          this.setState({ comments: comments });
        }.bind(this),
        error: function(xhr, status, err) {
          console.error(this.props.url, status, err.toString());
        }.bind(this)
      });
    },
    render: function() {
      var githubIssueUrl = 'https://github.com/' + this.props.github_full_name + '/issues/' + this.props.number;
      return (
        <div className='issueModal'>
          <h1>{this.state.issue.title} <a href={githubIssueUrl}>#{this.state.issue.number}</a></h1>
          <CloseButton onButtonClick={this.handleCloseButton} />
          <LabelList data={this.props.labels} />

          <CommentList data={this.state.comments} />
          <CommentForm onCommentSubmit={this.handleCommentSubmit} />
        </div>
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
        return (<Label key={label.id} color={label.color}>{label.name}</Label>);
      });
      return (
        <div>
          <EditButton name='Labels' onButtonClick={this.handleEditButtonClick} />
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
      return this.props.onButtonClick();
    },
    render: function() {
      return (
        <div onClick={this.handleClick}>{this.props.name}</div>
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

  var Label = React.createClass({
    render: function() {
      return (
        <div className="label" style={{color: this.props.color}}>
          {this.props.children}
        </div>
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

  var labels = [
    { id: 1, name: 'feature', color: 'blue' },
    { id: 2, name: 'bug', color: 'red' }
  ];

  window.IssueModalRender = function(number, github_full_name) {
    ReactDOM.render(
      <IssueModal number={number} github_full_name={github_full_name} labels={labels} />,
      document.getElementById('issue-modal')
    );
  }

});
