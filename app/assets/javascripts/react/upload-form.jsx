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
    const globalContainer = $('.issue-modal-container');
    const url = globalContainer.data('direct_post_url')
    const form_data = globalContainer.data('direct_post_form_data')
    const store_key = form_data['key'];
    const $input = $(this.refs.uploadFile);

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

      add: function(e, data) {
        types = /(\.|\/)(gif|jpe?g|png)$/i;
        file = data.files[0];
        if (types.test(file.type) || types.test(file.name)) {
          const sanitizedFileName = file.name.replace(/\s+/g, '-');
          form_data['key'] = store_key.replace('${filename}', sanitizedFileName);
          data.formData = form_data;

          data.submit();
        } else {
          this.setState({labelText: 'Unfortunately, we don’t support that file type. Try again with a PNG, GIF, JPG'});
        }
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
    if (this.state.display == 'none') {
      return true;
    }
    if ($input.closest('.comment-form').length && $('.comment.editable').length) {
      return true;
    }
    return false;
  },
  uploadDone: function(imageUrl) {
    this.props.onUpload(imageUrl);
  },

  render() {
    return (
      <form className='directUpload' style={{display: this.props.display}}>
        <a>{this.state.labelText}</a>
        <input ref='uploadFile' type='file' name='/[img]' id='_img' />
      </form>
    );
  }
});
