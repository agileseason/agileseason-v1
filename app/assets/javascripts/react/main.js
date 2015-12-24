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
    issueCommentsUrl: function() {
      return this.issueUrl() + '/comments';
    },
    getInitialState: function() {
      return { issue: { number: this.props.number, title: '...' }, comments: [] };
    },
    loadCommentFromServer: function() {
      $.ajax({
        url: this.issueCommentsUrl(),
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
    handleCommentSubmit: function(comment) {
      // TODO: submit to the server and refresh the list
      //alert(comment.body);

      $.ajax({
        url: this.issueUrl() + '/comment',
        dataType: 'json',
        type: 'POST',
        data: { 'comment': comment},
        success: function(comments) {
          this.setState({comments: comments});
        }.bind(this),
        error: function(xhr, status, err) {
          console.error(this.props.url, status, err.toString());
        }.bind(this)
      });
    },
    render: function() {
      return (
        <div className="issueModal">
          <h1>Issue #{this.state.issue.number}</h1>
          <h2>{this.state.issue.title}</h2>
          <CommentList data={this.state.comments} />
          <CommentForm onCommentSubmit={this.handleCommentSubmit} />
        </div>
      );
    }
  });

  var CommentList = React.createClass({
    getInitialState: function() {
      return { data: this.props.data };
    },
    componentDidMount: function() {
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


  window.IssueModalRender = function(number) {
    ReactDOM.render(
      <IssueModal number={number} />,
      document.getElementById('issue-modal')
    );
  }

});
