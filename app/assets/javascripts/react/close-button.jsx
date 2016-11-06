var React = require('react');
var ReactDOM = require('react-dom');

// CloseButton
module.exports = React.createClass({
  handleClick: function(e) {
    e.preventDefault();
    this.props.onButtonClick();
  },
  render: function() {
    return (<div className='close-modal' onClick={this.handleClick}></div>)
  }
});
