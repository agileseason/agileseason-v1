var React = require('react');
var ReactDOM = require('react-dom');

// ColorPicker
module.exports = React.createClass({
  render: function() {
    // NOTE: Other example colors set:
    //       #ffffff #ff8a80 #ffd180 #ffff8d #80d8ff #a7ffeb #ccff90 #e1bee7
    var colors = [
      '#ffffff', '#ffcdd2', '#ffe0b2', '#fff59d',
      '#b3e5fc', '#a7ffeb', '#dcedc8', '#e1bee7'
    ].map(function(color) {
      return (
        <Color key={color} color={color} onColorChange={this.props.onColorChange} />
      );
    }.bind(this));
    return (
      <div className='color-picker' style={{display: this.props.display}}>
        {colors}
      </div>
    );
  }
});

var Color = React.createClass({
  handleClick: function() {
    return this.props.onColorChange(this.props.color);
  },
  render: function() {
    return (
      <div
        className='color'
        onClick={this.handleClick}
        style={{backgroundColor: this.props.color}}
      />
    );
  }
});
