var React = require('react');
var ReactDOM = require('react-dom');

module.exports = React.createClass({
  getInitialState: function() {
    return { labelText: 'Attach images' };
  },
  getDefaultProps: function() {
    return { display: 'block' }
  },
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
        if (this.isNeedSkip($(e.target))) {
          return;
        }
        this.setState({labelText: 'Please wait...'});
      }.bind(this),
      done: function(e, data) {
        if (this.isNeedSkip($(e.target))) {
          return;
        }
        key = $(data.jqXHR.responseXML).find('Key').text();
        this.uploadDone(this.getImageUrl(url, key));
        this.setState({labelText: 'Attach images'});
      }.bind(this),
      fail: function(e, data) {
        console.error('Fail file upload!');
        this.setState({labelText: 'Attach images [Error. Please try again later.]'});
      }.bind(this)
    });
  },
  getImageUrl: function(url, key) {
    var lengthOfHash = 37;
    var name = key.substring(0, key.length - lengthOfHash)
    return '![' + name + '](' + url + '/' + key + ')';
  },
  isNeedSkip: function($input) {
    if ($input.closest('.comment-form').length && $('.comment.editable').length) {
      return true;
    }
    return false;
  },
  uploadDone: function(imageUrl) {
    this.props.onUpload(imageUrl);
  },
  render: function() {
    return (
      <form className='directUpload' style={{display: this.props.display}}>
        <a>{this.state.labelText}</a>
        <input ref='uploadFile' type='file' name='/[img]' id='_img' />
      </form>
    );
  }
});
