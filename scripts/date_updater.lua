obs = obslua

DATE_SOURCE_NAME = nil

function update_date(source_name)
    local date_source = obs.obs_get_source_by_name(source_name)
    local date = os.date("%d.%m.%Y")
    if date_source ~= nil then
        print(string.format("Updating source '%s' to %s.", source_name, date))
        local settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", date)
        obs.obs_source_update(date_source, settings)
        obs.obs_data_release(settings)
    end

    obs.obs_source_release(date_source)
end

function ui_finished_loading_callback(event)
    if event == obs.OBS_FRONTEND_EVENT_FINISHED_LOADING then
        update_date(DATE_SOURCE_NAME)
    end
end

function script_update(s)
    DATE_SOURCE_NAME = obs.obs_data_get_string(s, "date_text")
    local enabled = obs.obs_data_get_bool(s, "enable")
    if enabled then
        obs.obs_frontend_remove_event_callback(ui_finished_loading_callback)
        obs.obs_frontend_add_event_callback(ui_finished_loading_callback)

        update_date(DATE_SOURCE_NAME)
    else
        obs.obs_frontend_remove_event_callback(ui_finished_loading_callback)
    end
end

function script_properties()
    local p = obs.obs_properties_create()

    obs.obs_properties_add_bool(p, "enable", "Enable script")

    -- Create a dropdown menu in the properties to select the date text source.
    local date_text_property = obs.obs_properties_add_list(p, "date_text", "Date Text Source",
        obs.OBS_COMBO_TYPE_EDITABLE,
        obs.OBS_COMBO_FORMAT_STRING)

    -- Find all text sources and provide them as options for the dropdown menu.
    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            source_id = obs.obs_source_get_id(source)
            if source_id == "text_gdiplus_v2" then
                local name = obs.obs_source_get_name(source)
                obs.obs_property_list_add_string(date_text_property, name, name)
            end
        end
    end
    obs.source_list_release(sources)

    return p
end

function script_defaults(s)
    obs.obs_data_set_default_bool(s, "enable", false)
end

function script_description()
    return
    [[Automatically updates the text in the given source to the current date.]]
end
