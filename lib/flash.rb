require 'json'

class Flash
    def initialize(req)
        # cookie = (req.cookies['_rails_lite_app_flash'] ? JSON.parse(req.cookies['_rails_lite_app_flash']) : {life_count: 1})
        # cookie = {life_count: 1} if cookie[:life_count] == 0

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
        # @flash[:life_count] = (@flash[:life_count] - 1)
        res.set_cookie("_rails_lite_app_flash", {path: "/", value: @flash.to_json})
    end
end
