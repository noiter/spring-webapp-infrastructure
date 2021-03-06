<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>
<head>
    <title>React</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/react/0.12.2/react.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/react/0.12.2/JSXTransformer.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/showdown/0.3.1/showdown.min.js"></script>
    <script src="<c:url value="/resources/js/page-components.js" />"></script>
</head>

<body>
    <div id="content"></div>
    <script type="text/jsx">
        var converter = new Showdown.converter();

        var data = [
            {author: "Pete Hunt", text: "This is one comment"},
            {author: "Jordan Walke", text: "This is *another* comment"}
        ];

        var Comment = React.createClass({
            render: function() {
                var rawMarkup = converter.makeHtml(this.props.children.toString());
                return (
                    <div className="comment">
                        <h2 className="commentAuthor">{this.props.author}</h2>
                        <span dangerouslySetInnerHTML={{__html: rawMarkup}} />
                    </div>
                );
            }
        });

        var CommentList = React.createClass({
            render: function() {
                var commentNodes = this.props.data.map(function(comment) {
                    return (
                        <Comment author={comment.author}>{comment.content}</Comment>
                    )
                });
                return (
                    <div className="commentList">
                        {commentNodes}
                    </div>
                );
            }
        });

        var CommentForm = React.createClass({
            handleSubmit: function(e) {
                e.preventDefault();
                console.log(this.refs);
                var author = this.refs.author.getDOMNode().value.trim();
                var text = this.refs.text.getDOMNode().value.trim();
                if (!text || !author) {
                    return;
                }
                this.props.onCommentSubmit({author: author, text: text});
                this.refs.author.getDOMNode().value = '';
                this.refs.text.getDOMNode().value = '';
            },
            render: function() {
                return (
                    <form className="commentForm" onSubmit={this.handleSubmit}>
                        <input type="text" placeholder="Your name" ref="author" />
                        <input type="text" placeholder="Say something..." ref="text" />
                        <input type="submit" value="Post" />
                    </form>
                );
            }
        });

        var CommentBox = React.createClass({
            loadCommentsFromServer: function() {
                $.ajax({
                    url: this.props.url,
                    dataType: 'json',
                    success: function(data) {
                        this.setState({data: data});
                    }.bind(this),
                    error: function(xhr, status, err) {
                        console.error(this.props.url, status, err.toString());
                    }.bind(this)
                });
            },
            getInitialState: function() {
                return {data: []};
            },
            componentDidMount: function() {
                this.loadCommentsFromServer();
                setInterval(this.loadCommentsFromServer, this.props.pollInterval);
            },
            handleCommentSubmit: function(comment) {
                $.ajax({
                    url: this.props.url,
                    dataType: 'json',
                    type: 'POST',
                    data: comment,
                    success: function(data) {
                        this.setState({data: data});
                    }.bind(this),
                    error: function(xhr, status, err) {
                        console.error(this.props.url, status, err.toString());
                    }.bind(this)
                });
            },
            render: function() {
                return (
                    <div className="commentBox">
                        <h1>Comments</h1>
                        <CommentList data={this.state.data}/>
                        <CommentForm onCommentSubmit={this.handleCommentSubmit}/>
                    </div>
                );
            }
        });

        React.render(
            <CommentBox url="rest/allComments" pollInterval={5000} />,
            document.getElementById('content')
        );
    </script>

</body>
</html>
