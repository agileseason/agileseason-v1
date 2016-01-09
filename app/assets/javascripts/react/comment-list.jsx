var React = require('react');
var ReactDOM = require('react-dom');

module.exports = React.createClass({
  render: function() {
    var commentNodes = this.props.data.map(function(comment) {
      if (comment.isStub) {
        return (
          <div key={comment.id} className='comment'>
            <div className='avatar stub' />
            <div className='body stub' />
          </div>
        );
      } else {
        return (
          <Comment
            data={comment}
            key={comment.id}
            onDeleteClick={this.props.onDeleteClick}
            onUpdateClick={this.props.onUpdateClick}
          />
        );
      }
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

var UploadForm = React.createClass({
  componentDidMount: function() {
    var globalContainer = $('.issue-modal-container');
    var url = globalContainer.data('direct_post_url')
    var form_data = globalContainer.data('direct_post_form_data')

    var $input = $(this.refs.uploadFile);
    $input.fileupload({
      fileInput: $input,
      url: url,
      type: 'POST',
      autoUpload: true,
      formData: form_data,
      paramName: 'file',
      dataType: 'XML',
      replaceFileInput: false,

      start: function(e) {
        console.log('Start file upload...');
      },
      done: function(e, data) {
        key = $(data.jqXHR.responseXML).find('Key').text();
        imageUrl = window.build_s3_image_url(url, key);
        this.uploadDone(imageUrl);
      }.bind(this),
      fail: function(e, data) {
        console.error('Fail file upload!');
      }
    });
  },
  uploadDone: function(imageUrl) {
    this.props.onUpload(imageUrl);
  },
  render: function() {
    return (
      <form className='directUpload' style={{display: this.props.display}}>
        <a>Attach images</a>
        <input ref='uploadFile' type='file' name='/[img]' id='_img' />
      </form>
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
  handleUpload: function(imageUrl) {
    if (this.state.display == 'none') {
      return;
    }
    this.setState({ body: this.state.body + imageUrl + "\n" });
    this.focusToEnd();
  },
  handleSubmit: function(e) {
    e.preventDefault();
    this.saveComment();
  },
  componentDidMount: function() {
    $(this.refs.textarea).on('keydown', function(e) {
      if (e.keyCode == 13 && (e.metaKey || e.ctrlKey)) {
        this.saveComment();
        return false;
      }
    }.bind(this));
  },
  componentDidUpdate: function() {
    var textarea = $(this.refs.textarea)
    if (!textarea.hasClass('elasticable')) {
      textarea.addClass('elasticable');
      textarea.elastic();
      this.focusToEnd();
    }
  },
  focusToEnd: function() {
    $(this.refs.textarea).focus().val('').val(this.state.body);
  },
  saveComment: function() {
    var body = this.state.body.trim();
    if (!body) {
      return;
    }
    $(this.refs.textarea).blur();
    this.props.onCommentSubmit({body: body});
  },
  render: function() {
    return (
      <div>
        <form
          className='comment-edit-form'
          onSubmit={this.handleSubmit}
          style={{display: this.props.display}}
        >
          <textarea
            ref='textarea'
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
        <UploadForm display={this.props.display} onUpload={this.handleUpload} />
      </div>
    );
  }
});
