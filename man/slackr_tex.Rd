% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/slackr_tex.R
\name{slackr_tex}
\alias{slackr_tex}
\title{Post a tex output to a Slack channel}
\usage{
slackr_tex(
  obj,
  channels = Sys.getenv("SLACK_CHANNEL"),
  token = Sys.getenv("SLACK_TOKEN"),
  ext = "png",
  path = NULL,
  title = NULL,
  initial_comment = NULL,
  thread_ts = NULL,
  ...
)
}
\arguments{
\item{obj}{character object containing tex to compile.}

\item{channels}{Comma-separated list of channel names or IDs where the file will be shared.}

\item{token}{Authentication token bearing required scopes.}

\item{ext}{character, type of format to return, can be tex, pdf, or any image device, Default: 'png'.}

\item{path}{character, path to save tex_preview outputs, if NULL then tempdir is used, Default: NULL.}

\item{title}{Title of file.}

\item{initial_comment}{The message text introducing the file in specified channels.}

\item{thread_ts}{Provide another message's ts value to upload this file as a reply. Never use a reply's ts value; use its parent instead.}

\item{...}{other arguments passed to \code{\link[texPreview:tex_preview]{texPreview::tex_preview()}}, see Details}
}
\value{
\code{httr} response object (invisibly)
}
\description{
Unlike the \code{\link[=slackr_dev]{slackr_dev()}} function, this one takes a \code{tex} object,
eliminating the need write to pdf and convert to png to pass to slack.
}
\details{
Please make sure \code{texPreview} package is installed before running this function.
For TeX setup refer to the
\href{https://github.com/mrkaye97/slackr#latex-for-slackr_tex}{Setup notes on \code{LaTeX}}.
}
\note{
You need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
Also, you can pass in \code{add_user=TRUE} as part of the \code{...}
parameters and the Slack API will post the message as your logged-in user
account (this will override anything set in \code{username})
}
\seealso{
\code{\link[texPreview:tex_preview]{texPreview::tex_preview()}}
}
\author{
Jonathan Sidi (aut)
}
