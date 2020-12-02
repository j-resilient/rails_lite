require 'json'

class Flash
    def initialize(req)
        @flash = (req.cookies['_rails_lite_app_flash'] ? JSON.parse(req.cookies['_rails_lite_app_flash']) : {})
    end

    def [](key)
        @flash[key.to_sym]
    end

    def []=(key, value)
        @flash[key.to_sym] = value
    end

    def store_flash(res)
        res.set_cookie("_rails_lite_app_flash", {path: "/", value: @flash.to_json})
    end
end
