var React = require('react');
var ReactDOM = require('react-dom');
var CloseButton = require('./close-button.jsx');
var Label = require('./label.jsx');

// IssueModalNew
module.exports = React.createClass({
  getInitialState: function() {
    return {
      title: '',
      selectedLabels: [],
      labels: this.props.labels
    };
  },
  componentDidMount: function() {
    var $textarea = $(this.refs.textarea);
    setTimeout(function() {
      if (!$textarea.hasClass('elasticable')) {
        $textarea.addClass('elasticable');
        $textarea.elastic();
      }
      $textarea.focus();
    }.bind(this), 10);

    $textarea.on('keydown', function(e) {
      if (e.keyCode == 13) {
        this.handleSubmit();
        return false;
      }
    }.bind(this));
  },
  // TODO: Remove jquery if issue-modal-container be React component.
  handleCloseButton: function() {
    $('.issue-modal-container').hide();
  },
  handleTextChange: function(e) {
    this.setState({title: e.target.value});
  },
  handleLabelChange: function(labelName, checked) {
    selectedLabels = this.state.selectedLabels;
    if (checked) {
      selectedLabels.push(labelName);
    } else {
      index = selectedLabels.indexOf(labelName);
      if (index > -1) {
        selectedLabels.splice(index, 1);
      }
    }
    this.setState({selectedLabels: selectedLabels});
  },
  handleSubmit: function() {
    if (this.state.title.trim() == '') {
      $(this.refs.textarea).focus();
      return false;
    }
    $.ajax({
      url: this.props.submitUrl,
      dataType: 'json',
      type: 'POST',
      data: {
        issue: {
          title: this.state.title,
          labels: this.state.selectedLabels
        }
      },
      cache: false,
      success: function(data) {
        var columnSelector = '#column_' + this.props.columnId;
        $(columnSelector + ' .issues').prepend(data.html);
        this.handleCloseButton();
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(status, err.toString());
        alert(err.toString());
      }.bind(this)
    });
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
        <textarea
          ref='textarea'
          placeholder='Issue title'
          onChange={this.handleTextChange}
        />
        <div className='label-list'>
          {labelNodes}
        </div>
        <div className='actions'>
          <div className='pull-right'>
            <a className='cancel' onClick={this.handleCloseButton}>Cancel</a>
            <a className='button' onClick={this.handleSubmit}>Submit new issue</a>
          </div>
        </div>
      </div>
    );
  }
});
