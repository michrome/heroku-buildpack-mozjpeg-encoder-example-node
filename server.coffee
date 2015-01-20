eco = require 'eco'
fs  = require 'fs'
http = require 'http'
path  = require 'path'
url = require 'url'

port = process.env.PORT || 5000
jpegs_dir = path.normalize('./images')

respond_with_index_or_jpeg = (req, res) ->
  request_path = url.parse(req.url, true).pathname
  if request_path == '/'
    respond_with_index(res)
  else
    respond_with_jpeg(res, request_path)

respond_with_index = (res) ->
    template = fs.readFileSync(path.join(__dirname, 'index.html.eco'), 'utf-8')
    res.writeHead 200,
      'Content-Type': 'text/html'
    res.end eco.render(template, images: jpeg_files_in_dir(jpegs_dir))

respond_with_jpeg = (res, request_path) ->
  decoded_request_path = decodeURI(request_path)
  jpeg_filepath = path.join(jpegs_dir, decoded_request_path)
  jpeg_filesize = fs.statSync(jpeg_filepath).size
  console.log "Serving #{jpeg_filepath} (#{jpeg_filesize} bytes)…"
  jpeg_file = fs.readFileSync(jpeg_filepath)
  res.writeHead 200,
    'Content-Type': 'image/jpeg'
  res.end(jpeg_file, 'binary')

jpeg_files_in_dir = (dir) ->
  all_files_in_dir = fs.readdirSync(dir)
  all_files_in_dir.filter (file) -> file.match /.(jpe?g)$/i

server = http.createServer().listen(port, '0.0.0.0')
server.on('request', respond_with_index_or_jpeg)
console.log "Server running on port #{port}"
