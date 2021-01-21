# CAMEL CASE ALL THE THINGS (for legacy support)

#' @rdname slackr_dev
#' @param ... Passed to superceded function
#' @export
dev.slackr <- function(...) {
  .Deprecated(new = 'slackr_dev')
  slackr_dev(...)
}

#' @rdname slackr_dev
#' @inheritDotParams dev.slackr
#' @export
dev_slackr <- function(...) {
  .Deprecated(new = 'slackr_dev')
  slackr_dev(...)
}

#' @rdname save_slackr
#' @inheritDotParams dev.slackr
#' @export
save.slackr <- function(...) {
  .Deprecated(new = 'save_slackr')
  save_slackr(...)
}

#' @rdname slackr_bot
#' @inheritDotParams dev.slackr
#' @export
slackrBot <- function(...) {
  .Deprecated(new = 'slackr_bot')
  slackr_bot(...)
}

#' @rdname slackr_chtrans
#' @inheritDotParams dev.slackr
#' @export
slackrChtrans <- function(...) {
  .Deprecated(new = 'slackr_chtrans')
  slackr_chtrans(...)
}

#' @rdname slackr_chtrans
#' @inheritDotParams dev.slackr
#' @export
slackrChTrans <- function(...) {
  .Deprecated(new = 'slackr_chtrans')
  slackr_chtrans(...)
}

#' @rdname slackr_channels
#' @inheritDotParams dev.slackr
#' @export
slackrChannels <- function(...) {
  .Deprecated(new = 'slackr_channels')
  slackr_channels(...)
}

#' @rdname slackr_ims
#' @inheritDotParams dev.slackr
#' @export
slackrIms <- function(...) {
  .Deprecated(new = 'slackr_ims')
  slackr_ims(...)
}

#' @rdname slackr_msg
#' @inheritDotParams dev.slackr
#' @export
slackrMsg <- function(...) {
  .Deprecated(new = 'slackr_msg')
  slackr_msg(...)
}

#' @rdname slackr_setup
#' @inheritDotParams dev.slackr
#' @export
slackrSetup <- function(...) {
  .Deprecated(new = 'slackr_setup')
  slackr_setup(...)
}

#' @rdname slackr_upload
#' @inheritDotParams dev.slackr
#' @export
slackrUpload <- function(...) {
  .Deprecated(new = 'slackr_upload')
  slackr_upload(...)
}

#' @rdname slackr_users
#' @inheritDotParams dev.slackr
#' @export
slackrUsers <- function(...) {
  .Deprecated(new = 'slackr_users')
  slackr_users(...)
}

#' @rdname text_slackr
#' @inheritDotParams dev.slackr
#' @export
textSlackr <- function(...) {
  .Deprecated(new = 'slackr_msg')
  slackr_msg(...)
}

#' @rdname text_slackr
#' @inheritDotParams dev.slackr
#' @export
text_slackr <- function(...) {
  .Deprecated(new = 'slackr_msg')
  slackr_msg(...)
}