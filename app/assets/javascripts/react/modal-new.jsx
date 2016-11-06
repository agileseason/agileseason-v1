var React = require('react');
var ReactDOM = require('react-dom');
var CloseButton = require('./close-button.jsx');
var Label = require('./label.jsx');

//window.IssueModalNew = React.createClass({
module.exports = React.createClass({
  getInitialState: function() {
    return {
      labels: this.props.labels,
    };
  },
  // TODO: Remove jquery if issue-modal-container be React component.
  handleCloseButton: function() {
    $('.issue-modal-container').hide();
  },
  handleLabelChange: function(labelName, checked) {
    console.log(labelName);
    console.log(checked);
  },
  render: function() {
    var labelNodes = this.props.labels.map(function(label) {
      return (
        <Label key={label.id} data={label} onLabelChange={this.handleLabelChange}>
          {label.name}
        </Label>
      );
    }.bind(this));
    return (
      <div className='issueModal'>
        <CloseButton onButtonClick={this.handleCloseButton} />
        <div className='label-list'>
          {labelNodes}
        </div>
      </div>
    );
  }
});
