require 'json'

class Flash
    def initialize(req)
        @cookie = (req.cookies['_rails_lite_app_flash'] ? JSON.parse(req.cookies['_rails_lite_app_flash']) : {}) 
        @flash = (req.cookies['_rails_lite_app_flash'] ? JSON.parse(req.cookies['_rails_lite_app_flash']) : {}) 
    end

    def [](key)
        key = key.to_s
        @flash[key]
    end

    def []=(key, value)
        key = key.to_s
        @flash[key] = value
    end

    def store_flash(res)
        @flash.reject! { |key, val| @cookie[key] == val }
        res.set_cookie("_rails_lite_app_flash", {path: "/", value: @flash.to_json})
    end
end
