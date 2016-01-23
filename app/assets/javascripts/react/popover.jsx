var React = require('react');
var ReactDOM = require('react-dom');

// PopoverOverlay
module.exports = React.createClass({
  handleClick: function() {
    return this.props.onOverlayClick();
  },
  render: function() {
    var cssClasses = 'popup-overlay escapeble ' + this.props.className;
    return (
      <div className={cssClasses} style={{display: this.props.display}} onClick={this.handleClick}></div>
    );
  }
});
