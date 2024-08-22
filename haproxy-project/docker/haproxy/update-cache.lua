core.register_service("update_total_max_size", "http", function(applet)
    -- Extract new cache size from custom HTTP header
    local new_total_max_size = applet.headers["cache-max-size"][0]

    -- Validate new cache size
    if not new_total_max_size or tonumber(new_total_max_size) == nil or tonumber(new_total_max_size) < 0 then
        applet:set_status(400)
        applet:add_header("Content-Type", "text/plain")
        applet:start_response()
        applet:send("Bad Request: Invalid total-max-size parameter " .. new_total_max_size)
        return
    end

    -- Update HAProxy configuration dynamically
    local base_cfg_file = "/usr/local/etc/haproxy/haproxy.cfg"
    local tmp_cfg_file = "/usr/local/etc/haproxy/haproxy.cfg.tmp"

    os.execute("cp " .. base_cfg_file .. " " .. tmp_cfg_file)
    local cmd = "awk '/total-max-size/ { sub(/total-max-size [0-9]+/, \"total-max-size " .. new_total_max_size .."\") } 1' " .. base_cfg_file .. " > " .. tmp_cfg_file

    os.execute(cmd)
    os.execute("cp " .. tmp_cfg_file .. " " .. base_cfg_file)
    os.execute("rm " .. tmp_cfg_file)
    os.execute("haproxy -D -f /usr/local/etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid) -x /var/run/haproxy.sock")

    -- Respond with success message
    applet:set_status(200)
    applet:add_header("Content-Type", "text/plain")
    applet:start_response()
    applet:send("Total-max-size updated successfully to: " .. new_total_max_size)
end)