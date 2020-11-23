// By @skull132/<@84559773487353856> on GitHub/Discord from paradise/aurora (tgstation/tgstation/pull/49374). Licensed to us under MIT(https://opensource.org/licenses/MIT).

/**
  * # HTTP Request
  *
  * Holder datum for ingame HTTP requests
  *
  * Holds information regarding to methods used, URL, and response,
  * as well as job IDs and progress tracking for async requests
  */
/datum/http_request
	var/id
	var/in_progress = FALSE

	var/method
	var/body
	var/headers
	var/url

	var/_raw_response

/datum/http_request/proc/prepare(method, url, body = "", list/headers)
	if (!length(headers))
		headers = ""
	else
		headers = json_encode(headers)

	src.method = method
	src.url = url
	src.body = body
	src.headers = headers

/datum/http_request/proc/execute_blocking()
	_raw_response = rustg_http_request_blocking(method, url, body, headers)

/datum/http_request/proc/begin_async()
	if (in_progress)
		stack_trace("Attempted to re-use a request object.")

	id = rustg_http_request_async(method, url, body, headers)

	if (isnull(text2num(id)))
		stack_trace("Proc error: [id]")
		_raw_response = "Proc error: [id]"
	else
		in_progress = TRUE

/datum/http_request/proc/is_complete()
	if (isnull(id))
		return TRUE

	if (!in_progress)
		return TRUE

	var/r = rustg_http_check_request(id)

	if (r == RUSTG_JOB_NO_RESULTS_YET)
		return FALSE
	else
		_raw_response = r
		in_progress = FALSE
		return TRUE

/datum/http_request/proc/into_response()
	var/datum/http_response/R = new()

	try
		var/list/L = json_decode(_raw_response)
		R.status_code = L["status_code"]
		R.headers = L["headers"]
		R.body = L["body"]
	catch
		R.errored = TRUE
		R.error = _raw_response

	if(R.status_code && R.status_code > 299) // ike709 edit: Treat non-200 codes as errors. // franc: raised to allow any valid 2xx code.
		R.errored = R.status_code
		//world.log << "Response marked as errored with |code [R.status_code]|destination URI [url]|"

	return R

/datum/http_response
	var/status_code
	var/body
	var/list/headers

	var/errored = FALSE
	var/error
