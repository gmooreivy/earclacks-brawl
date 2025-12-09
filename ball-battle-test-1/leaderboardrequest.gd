extends HTTPRequest
request_completed.connect(self._on_request_completed)

func _ready():
	
