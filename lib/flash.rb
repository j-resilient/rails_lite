require 'json'

class Flash
    attr_accessor :now

    def initialize(req)
        # a copy of the cookie
        @cookie = (req.cookies['_rails_lite_app_flash'] ? JSON.parse(req.cookies['_rails_lite_app_flash']) : {}) 
        # the actual flash object
        @flash = (req.cookies['_rails_lite_app_flash'] ? JSON.parse(req.cookies['_rails_lite_app_flash']) : {}) 
        # the flash.now object
        @now = {}
    end

    def [](key)
        key = key.to_s
        # if key exists on flash object, return that
        # else if flash.now object contains key, return that
        # else return nil
        @flash[key] || @now[key]
    end

    def []=(key, value)
        @flash[key.to_s] = value
    end

    def store_flash(res)
        # get rid of any values from the last cycle before returning response
        @flash.reject! { |key, val| @cookie[key] == val }
        res.set_cookie("_rails_lite_app_flash", {path: "/", value: @flash.to_json})
    end
end
