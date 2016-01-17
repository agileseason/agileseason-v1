var React = require('react');
var ReactDOM = require('react-dom');

// PopoverOverlay
module.exports = React.createClass({
  handleClick: function() {
    return this.props.onOverlayClick();
  },
  render: function() {
    return (
      <div className='popup-overlay escapeble' style={{display: this.props.display}} onClick={this.handleClick}></div>
    );
  }
});
