var React = require('react');
var ReactDOM = require('react-dom');
var CloseButton = require('./close-button.jsx');
var Label = require('./label.jsx');
var ColorPicker = require('./color-picker.jsx');

// IssueModalNew
module.exports = React.createClass({
  getInitialState: function() {
    return {
      title: '',
      selectedLabels: [],
      selectedColor: '#fff',
      labels: this.props.labels,
      displayOption: 'none',
      isSubmiting: false,
      submitButtonText: 'Submit new issue'
    };
  },

  componentDidMount: function() {
    this.handleColorOnChange(this.state.selectedColor);
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
    if (this.state.isSubmiting) {
      return false;
    }
    if (this.state.title.trim() == '') {
      $(this.refs.textarea).focus();
      return false;
    }

    this.setState({ isSubmiting: true, submitButtonText: 'Submit new issue...' })
    $.ajax({
      url: this.props.submitUrl,
      dataType: 'json',
      type: 'POST',
      data: {
        issue: {
          title: this.state.title,
          labels: this.state.selectedLabels,
          color: this.state.selectedColor
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
        this.setState({ isSubmiting: false, submitButtonText: 'Submit new issue' })
      }.bind(this)
    });
  },

  handerOption: function() {
    if (this.state.displayOption == 'none') {
      displayOption = 'block';
    } else {
      displayOption = 'none';
    }
    this.setState({displayOption: displayOption});
  },

  handleColorOnChange: function(color) {
    this.setState({selectedColor: color});
    $('.issue-modal-new').css('background-color', color);
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
          <a className='options' onClick={this.handerOption}>Options</a>
          <input type='submit'
            className='button pull-right'
            onClick={this.handleSubmit}
            value={this.state.submitButtonText}
          />
        </div>
        <div className='options-block' style={{display: this.state.displayOption}}>
          <ColorPicker
            display={'block'}
            onColorChange={this.handleColorOnChange}
          />
        </div>
      </div>
    );
  }
});
