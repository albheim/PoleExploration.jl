module PoleExploration

using Mux, WebIO, Interact

export start_server

function app(req)

end


start_server() = webio_serve(page("/", app), 8000)

end # module
