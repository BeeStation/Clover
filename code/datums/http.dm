// http.dm is licensed under the MIT license:
/*
MIT License

Copyright (c) 2020 Skull132

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/proc/http_create_request(method, url, body = "", list/headers)
	var/datum/http_request/R = new()
	R.prepare(method, url, body, headers)

	return R

/proc/http_create_get(url, body = "", list/headers)
	return http_create_request(RUSTG_HTTP_METHOD_GET, url, body, headers)

/proc/http_create_post(url, body = "", list/headers)
	return http_create_request(RUSTG_HTTP_METHOD_POST, url, body, headers)

/proc/http_create_put(url, body = "", list/headers)
	return http_create_request(RUSTG_HTTP_METHOD_PUT, url, body, headers)

/proc/http_create_delete(url, body = "", list/headers)
	return http_create_request(RUSTG_HTTP_METHOD_DELETE, url, body, headers)

/proc/http_create_patch(url, body = "", list/headers)
	return http_create_request(RUSTG_HTTP_METHOD_PATCH, url, body, headers)

/proc/http_create_head(url, body = "", list/headers)
	return http_create_request(RUSTG_HTTP_METHOD_HEAD, url, body, headers)

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

	if(R.status_code && R.status_code != 200) // ike709 edit: Treat non-200 codes as errors.
		R.errored = R.status_code
		//world.log << "Response marked as errored with |code [R.status_code]|destination URI [url]|"

	return R

/datum/http_response
	var/status_code
	var/body
	var/list/headers

	var/errored = FALSE
	var/error
