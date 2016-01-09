var React = require('react');
var ReactDOM = require('react-dom');

// Title
module.exports = React.createClass({
  getInitialState: function() {
    return {
      title: this.props.title,
      h1: 'block',
      textarea: 'none'
    };
  },
  componentDidUpdate: function() {
    var $textarea = $(this.refs.title)
    if (!$textarea.hasClass('elasticable')) {
      $textarea.addClass('elasticable');
      $textarea.elastic();
    }
    if (this.state.textarea == 'block') {
      $textarea.focus().val('').val(this.state.title);
    }
  },
  handleEditTitleClick: function() {
    var title = this.state.title.trim();
    if (title == '') {
      return;
    }
    if (this.state.h1 == 'block') {
      this.setState({h1: 'none', textarea: 'block'});
    } else {
      this.setState({h1: 'block', textarea: 'none'});
      this.props.onUpdateTitle(title);
    }
  },
  handleTextChange: function(e) {
    this.setState({title: e.target.value});
  },
  handleKeyDown: function(e) {
    if (e.keyCode == 13) {
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
        </h1>
        <textarea
          ref='title'
          type='text'
          placeholder='Edit title'
          value={this.state.title}
          onChange={this.handleTextChange}
          onBlur={this.handleEditTitleClick}
          onKeyDown={this.handleKeyDown}
          style={{display: this.state.textarea}}
        />
      </div>
    );
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
