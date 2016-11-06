var React = require('react');
var ReactDOM = require('react-dom');

// Label
module.exports = React.createClass({
  getInitialState: function() {
    return { checked: this.props.data.checked }
  },
  handleChange: function() {
    this.setState({ checked: this.refs.labelCheckbox.checked });
    this.props.onLabelChange(this.props.children, this.refs.labelCheckbox.checked);
  },
  render: function() {
    return (
      <label
        className='label'
        style={{backgroundColor: this.props.data.backgroundColor, color: this.props.data.color}}>
        <input
          type='checkbox'
          checked={this.state.checked}
          ref='labelCheckbox'
          onChange={this.handleChange}
        />
        {this.props.children}
      </label>
    );
  }
});
