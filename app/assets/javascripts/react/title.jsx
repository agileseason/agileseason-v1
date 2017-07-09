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
      var $textarea = $(this.refs.title);
      var isNeedElastic = !$textarea.hasClass('elasticable');

      if (isNeedElastic) {
        $textarea.css('height',
          $textarea.parent().find('h1').height().toString() + 'px');
        setTimeout(function() {
          $textarea.addClass('elasticable');
          $textarea.elastic();
        }.bind(this), 10);
      }
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
          <span onClick={this.handleEditTitleClick}>
            {`${this.state.title}\n`}
          </span>
          <a href={this.props.url}>#{this.props.number}</a>
          <CurrentDueDate
            date={this.props.dueDate}
            state={this.props.state}
            closedAt={this.props.closedAt}
          />
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
      return (
        <div className='current-state'>
          <span className='octicon octicon-issue-closed'></span>
          <span>Closed</span>
        </div>
      );
    }

    if (this.props.data == 'archive' || this.props.data == 'archived') {
      return (
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
    }

    return <span />
  }
});

var CurrentDueDate = React.createClass({
  render: function() {
    if (this.props.date) {
      return (
        <div
          className={this.dueDateClasses()}
          title='Due Date'
        >
          {this.getDate()}
        </div>
      );
    }

    return <span />
  },

  getDate: function() {
    if (this.props.date) {
      var date = this.dueDate();
      var yearStr = (new Date()).getUTCFullYear() == date.getUTCFullYear() ? '' : '.' + date.getUTCFullYear();
      var dateStr = (date.getUTCDate()).pad() + '.' + (date.getUTCMonth() + 1).pad() + yearStr;
      var timeStr = (date.getUTCHours()).pad() + ':' + (date.getUTCMinutes()).pad();

      return dateStr + ' ' + timeStr;
    }

    return '';
  },

  dueDate: function() {
    return new Date(this.props.date);
  },

  dueDateClasses: function() {
    if (this.props.state == 'closed' || this.props.state == 'close') {
      var closedAt = new Date(this.props.closedAt);
      if (closedAt <= this.dueDate()) { return 'current-due-date success'; }
    }

    if (this.dueDate() < new Date()) {
      return 'current-due-date passed';
    }

    return 'current-due-date';
  }
});
