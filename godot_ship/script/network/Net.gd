extends Node

const DEFAULT_PORT = 35879
const LOCALHOST = "127.0.0.1"

signal incoming

# Let's pretend this is actually passed from send to receive
class Mail:
	# Sender address
	var from:int
	var message
	var type:int
	enum {FROM, MESSAGE, TYPE}
	enum {REPLY, REQUEST}

# Store peer info in a dictionary, by player ID
var peer_info = {}
# Store this player's hostname
var local_info = {"hostname": ""}

var connected = false
var hosting = false

# FIFO queue of Mails
var inbox = []

# Network -- handles server and client setup, and facilitates communication between the two
#   receive: Called when an incoming message is received
#     item: The message received from the sender
sync func receive(mail):
	# Get the sender's ID and force letter to be properly addressed
	mail[0] = get_tree().get_rpc_sender_id()
	# Add the mail to the inbox (so it can be read back later if necessary
	inbox.append(mail)
	# Sent it off to anything that expects mail
	emit_signal("incoming", mail)

#   send: Called when sending a message
#     id: Peer ID of the recipient
#     mail: Variant of a json-encodable type (non-Object) to send
func send(id, mail):
	# Make the recipient receive the mail
	rpc_id(id, "receive", to_json(mail))

#   start_host: Host the game
#     port: TCP port
#     max_players: Largest number of players allowed to connect at a time
func start_host(port = DEFAULT_PORT, max_players = 2):
	get_hostname()
	peer_info[1] = local_info
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, max_players)
	get_tree().network_peer = peer
	connected = true
	hosting = true
	return

#   connect_host: Connect to a host
func connect_host(ip = LOCALHOST, port = DEFAULT_PORT):
	get_hostname()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().network_peer = peer

#   disconnect_host
func disconnect_host():
	# Set state to disconnected
	connected = false
	hosting = false
	# Attempt disconnection
	if get_tree().network_peer:
		get_tree().network_peer.close_connection()
	# Disconnect
	get_tree().network_peer = null
	# Clear peer info
	peer_info = {}

func get_hostname():
	if local_info["hostname"] == "":
		var hostname = []
		var _ret = OS.execute("hostname", [], true, hostname)
		local_info["hostname"] = hostname[0].split("\n")[0]
	return local_info["hostname"]

func get_network_id():
	return get_tree().get_network_unique_id()

func get_ip():
	print(IP.resolve_hostname(get_hostname(), IP.TYPE_IPV4))
	pass

func _ready():
	var _trash 
	_trash = get_tree().connect("network_peer_connected",    self, "_peer_connected"   )
	_trash = get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	_trash = get_tree().connect("connected_to_server",       self, "_host_connected"   )
	_trash = get_tree().connect("server_disconnected",       self, "_host_disconnected")
	_trash = get_tree().connect("connection_failed",         self, "_connection_fail"  )


func _peer_connected(id):
	rpc_id(id, "register_peer", local_info)
	pass

func _peer_disconnected(id):
	peer_info.erase(id)
	pass


func _host_connected():
	# On connection to the server, you get a global network id
	# Save your info at this id
	peer_info[get_network_id()] = local_info
	# Set state to connected
	connected = true

func _host_disconnected():
	# Ensure host is disconnected
	disconnect_host()

func _connection_fail():
	# Ensure Net state is clear
	disconnect_host()

remote func register_peer(info):
	# Save player information under the sender id's peer info
	peer_info[get_tree().get_rpc_sender_id()] = info
	pass
