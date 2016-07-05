var React = require('react');
var ReactDOM = require('react-dom');

var PopoverOverlay = require('./popover.jsx');

// Title
module.exports = React.createClass({
  getInitialState: function() {
    return {
      title: this.props.title,
      titleEdit: this.props.title,
      h1: 'block',
      textarea: 'none'
    };
  },
  componentDidMount: function() {
    var $textarea = $(this.refs.title);
    $textarea.on('blur', function() {
      if (this.state.textarea == 'block') {
        this.handleEditTitleClick();
      }
    }.bind(this));
  },
  componentWillUpdate: function(newProps, newState) {
    if (newState.textarea == 'block') {
      setTimeout(function() {
        var $textarea = $(this.refs.title);
        if (!$textarea.hasClass('elasticable')) {
          $textarea.addClass('elasticable');
          $textarea.elastic();
        }
      }.bind(this), 10);
    }
  },
  componentDidUpdate: function() {
    if (this.state.textarea == 'block') {
      var $textarea = $(this.refs.title);
      if (!$textarea.is(':focus')) {
        $textarea.focus().val('').val(this.state.titleEdit);
      }
    }
  },
  handleEditTitleClick: function() {
    if (this.props.isReadonly) {
      return;
    }
    if (this.state.h1 == 'block') {
      this.setState({h1: 'none', textarea: 'block'});
    } else {
      this.setState({h1: 'block', textarea: 'none'});
    }
  },
  handleTextChange: function(e) {
    this.setState({titleEdit: e.target.value});
  },
  handleKeyDown: function(e) {
    if (e.keyCode == 13) {
      var title = this.state.titleEdit.trim();
      if (title == '') {
        return;
      }
      this.props.onUpdateTitle(title);
      this.setState({title: title});
      this.handleEditTitleClick();
    }
  },
  render: function() {
    return(
      <div className='issue-title'>
        <h1 style={{display: this.state.h1}}>
          <span onClick={this.handleEditTitleClick}>{this.state.title}</span>
          <a href={this.props.url}>#{this.props.number}</a>
          <CurrentDueDate data={this.props.dueDate} />
          <CurrentState data={this.props.state} />
        </h1>
        <textarea
          ref='title'
          type='text'
          value={this.state.titleEdit}
          onChange={this.handleTextChange}
          onKeyDown={this.handleKeyDown}
          placeholder='Edit title'
          style={{display: this.state.textarea}}
          className='elastic-min-height'
        />
        <PopoverOverlay
          className='fake'
          display={this.state.textarea}
          onOverlayClick={this.handleEditTitleClick}
        />
      </div>
    );
  }
});

var CurrentState = React.createClass({
  render: function() {
    if (this.props.data == 'close' || this.props.data == 'closed' || this.props.data == 'unarchive') {
      return(
        <div className='current-state'>
          <span className='octicon octicon-issue-closed'></span>
          <span>Closed</span>
        </div>
      );
    } else if (this.props.data == 'archive' || this.props.data == 'archived') {
      return(
        <div className='states-box'>
          <div className='current-state'>
            <span className='octicon octicon-issue-closed'></span>
            <span>Closed</span>
          </div>
          <div className='current-state'>
            <span className='octicon octicon-package'></span>
            <span>Archived</span>
          </div>
        </div>
      );
    } else {
      return <span />
    }
  }
});

var CurrentDueDate = React.createClass({
  getDate: function() {
    var res = '';
    if (this.props.data) {
      var date = new Date(this.props.data);
      var yearStr = (new Date()).getUTCFullYear() == date.getUTCFullYear() ? '' : '.' + date.getUTCFullYear();
      res = (date.getUTCDate()).pad() + '.' + (date.getUTCMonth() + 1).pad() + yearStr
        + ' ' + (date.getUTCHours()).pad() + ':' + (date.getUTCMinutes()).pad();
    }
    return res;
  },
  render: function() {
    if (this.props.data) {
      return <div className='current-due-date' title='Due Date'>{this.getDate()}</div>;
    } else {
      return <span />
    }
  }
});
