class_name ArchiveData

var events: Array[Dictionary] = []

func add_event(event_id: String, time_str: String, title: String, description: String) -> void:
    events.append({
        "id": event_id,
        "time": time_str,
        "title": title,
        "description": description
    })

func get_events_by_year(year: int) -> Array[Dictionary]:
    var prefix = str(year)
    var result: Array[Dictionary] = []
    for e in events:
        var t = str(e.get("time", ""))
        if t.begins_with(prefix):
            result.append(e)
    return result

func get_events_by_year_range(from_year: int, to_year: int) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for e in events:
        var t = str(e.get("time", ""))
        var parts = t.split("-")
        if parts.size() > 0:
            var ey = parts[0].to_int()
            if ey >= from_year and ey <= to_year:
                result.append(e)
    return result

func get_all_events() -> Array[Dictionary]:
    return events.duplicate(true)

func clear() -> void:
    events.clear()
