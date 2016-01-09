var React = require('react');
var ReactDOM = require('react-dom');

module.exports = React.createClass({
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
