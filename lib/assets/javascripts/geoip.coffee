(($) ->
  class window.GeoIP
    constructor: ->
      @stored_callbacks = {}

    loadGeoIPData: (ip_address, callback) ->
      if ip_address == '::1' || ip_address == '127.0.0.1'
        callback(city: 'localhost')
        return

      @stored_callbacks[ip_address] ||= []
      @stored_callbacks[ip_address].push callback

      if data = @getGeoIPData(ip_address)
        # Load stored geo ip data
        @setGeoIPData(ip_address, data)
      else if @stored_callbacks[ip_address].length > 1
        # Wait for other callbacks to finish
      else
        # Load GeoIP Data from freegeoip.net
        url = "https://freegeoip.net/json/#{ip_address}"
        $.get url, {}, ((data, textStatus, jqXHR) =>
          @setGeoIPData(ip_address, {
            city: data.city,
            country: data.country_name,
            state: data.region_name
          })
        ), 'json'

    updateGeocodedTags: ->
      geo_ip = @
      $('[data-geocode-ip]').each ->
        ip_address = $(this).data('geocode-ip')
        geo_ip.loadGeoIPData ip_address, (data) =>
          value = data.city
          if value && value.length
            value += ", #{data.state}" if data.state
            value += ", #{data.country}" if data.country
          else
            value = ip_address
          $(this).text(value)

    getGeoIPData: (ip_address) ->
      value = Cookies.get("geoip_#{ip_address}")
      JSON.parse(value) if value

    setGeoIPData: (ip_address, data) ->
      Cookies.set("geoip_#{ip_address}", JSON.stringify(data))
      callback(data) for callback in @stored_callbacks[ip_address]
      @stored_callbacks[ip_address] = []
      return
)(jQuery)
