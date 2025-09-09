import { ChevronDown, MessageCircle, Send, User, Users } from "lucide-react";
import React, { useEffect, useRef, useState } from "react";
import { useToast } from "../../contexts/ToastContext";
import { activityAPI, chatAPI } from "../../services/api";

interface ChatUser {
  id: string;
  name: string;
  email: string;
  role: string;
  department: string;
  lastMessage?: string;
  lastMessageTime?: string;
  unreadCount?: number;
}

interface Message {
  id: string;
  senderId: string;
  senderName: string;
  receiverId: string;
  receiverName: string;
  message: string;
  timestamp: string;
  read: boolean;
}

interface Conversation {
  user: ChatUser;
  lastMessage: Message | null;
  unreadCount: number;
}

const UserChat: React.FC = React.memo(() => {
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [allUsers, setAllUsers] = useState<ChatUser[]>([]);
  const [filteredUsers, setFilteredUsers] = useState<ChatUser[]>([]);
  const [selectedUser, setSelectedUser] = useState<ChatUser | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [newMessage, setNewMessage] = useState("");
  const [loading, setLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedFilter, setSelectedFilter] = useState("all");
  const [showUserDropdown, setShowUserDropdown] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const [isSearching, setIsSearching] = useState(false);

  const { showToast } = useToast();

  useEffect(() => {
    loadInitialData();
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    // Debounce search
    const searchTimeout = setTimeout(() => {
      if (searchQuery.trim()) {
        performSearch();
      } else {
        filterUsers();
      }
    }, 300);

    return () => clearTimeout(searchTimeout);
  }, [searchQuery, selectedFilter]);

  useEffect(() => {
    // Update filtered users when allUsers changes
    if (!searchQuery.trim()) {
      filterUsers();
    }
  }, [allUsers]);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(event.target as Node)
      ) {
        setShowUserDropdown(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const performSearch = async () => {
    if (!searchQuery.trim()) {
      filterUsers();
      return;
    }

    setIsSearching(true);
    try {
      // Instead of making a new API call, search within the existing allUsers data
      // which already includes data from both User table and Alumni table
      filterUsers();
    } catch (error: any) {
      console.error("Search failed:", error);
      // Fallback to local filtering
      filterUsers();
    } finally {
      setIsSearching(false);
    }
  };

  const loadInitialData = async () => {
    try {
      // Load all conversations and users
      await Promise.all([loadConversations(), loadAllUsers()]);
    } catch (error: any) {
      showToast(error.message || "Failed to load chat data", "error");
    }
  };

  const loadConversations = async () => {
    try {
      console.log("UserChat: Loading conversations...");
      const response = await chatAPI.getConversations();
      console.log("UserChat: Conversations loaded:", response.length);
      setConversations(response);
    } catch (error: any) {
      console.error("UserChat: Failed to load conversations:", error);
      console.error("UserChat: Conversation error details:", {
        message: error.message,
        status: error.response?.status,
        statusText: error.response?.statusText,
        data: error.response?.data,
      });
      setConversations([]);
    }
  };

  const loadAllUsers = async () => {
    try {
      console.log("UserChat: Starting to load all users...");
      console.log("UserChat: Making API call to /chat/users");

      const response = await chatAPI.getAllUsers();
      console.log("UserChat: Users loaded successfully:", response.length);
      console.log("UserChat: Sample users:", response.slice(0, 3));
      console.log(
        "UserChat: User roles breakdown:",
        response.reduce((acc: any, user: ChatUser) => {
          acc[user.role] = (acc[user.role] || 0) + 1;
          return acc;
        }, {})
      );
      setAllUsers(response);
    } catch (error: any) {
      console.error("UserChat: Failed to load users:", error);
      console.error("UserChat: Error details:", {
        message: error.message,
        status: error.response?.status,
        statusText: error.response?.statusText,
        data: error.response?.data,
      });
      setAllUsers([]);
      showToast("Failed to load users for chat", "error");
    }
  };

  const filterUsers = () => {
    // Get current user ID to filter out
    const currentUserId = getCurrentUserId();
    let filtered = allUsers.filter((user) => user.id !== currentUserId);

    console.log(
      "UserChat: Filtering users. Total before filter:",
      filtered.length
    );
    console.log("UserChat: Selected filter:", selectedFilter);
    console.log("UserChat: Search query:", searchQuery);

    // Filter by role - handle case insensitive comparison
    if (selectedFilter !== "all") {
      const beforeRoleFilter = filtered.length;
      filtered = filtered.filter((user) => {
        const userRole = user.role.toLowerCase();
        const filterRole = selectedFilter.toLowerCase();
        return userRole === filterRole;
      });
      console.log(
        `UserChat: After role filter (${selectedFilter}): ${filtered.length} (was ${beforeRoleFilter})`
      );
    }

    // Filter by search query - enhanced search including phone numbers
    if (searchQuery.trim()) {
      const beforeSearchFilter = filtered.length;
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(
        (user) =>
          user.name.toLowerCase().includes(query) ||
          user.email.toLowerCase().includes(query) ||
          user.email.split("@")[0].toLowerCase().includes(query) ||
          (user.department && user.department.toLowerCase().includes(query))
      );
      console.log(
        `UserChat: After search filter (${searchQuery}): ${filtered.length} (was ${beforeSearchFilter})`
      );
    }

    console.log("UserChat: Final filtered users:", filtered.length);
    setFilteredUsers(filtered);
  };

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  const selectUser = async (user: ChatUser) => {
    setSelectedUser(user);
    setShowUserDropdown(false);
    setSearchQuery("");

    // Load chat history
    try {
      const response = await chatAPI.getChatHistory(user.id);
      setMessages(response);

      // Mark messages as read
      await chatAPI.markMessagesAsRead(user.id);

      // Update conversations
      loadConversations();
    } catch (error: any) {
      showToast(error.message || "Failed to load chat history", "error");
    }
  };

  const sendMessage = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!newMessage.trim() || !selectedUser || loading) return;

    setLoading(true);
    try {
      const response = await chatAPI.sendMessage({
        receiverId: selectedUser.id,
        message: newMessage,
      });

      setMessages((prev) => [...prev, response]);
      setNewMessage("");

      // Update conversations
      loadConversations();

      // Log activity
      const activityType =
        selectedUser.role === "ALUMNI"
          ? "ALUMNI_CHAT"
          : selectedUser.role === "PROFESSOR"
          ? "PROFESSOR_CHAT"
          : "ALUMNI_CHAT";
      try {
        await activityAPI.logActivity(
          activityType,
          `Sent message to ${selectedUser.name}`
        );
      } catch (activityError) {
        console.warn("Failed to log chat activity:", activityError);
      }

      showToast("Message sent successfully!", "success");
    } catch (error: any) {
      showToast(error.message || "Failed to send message", "error");
    } finally {
      setLoading(false);
    }
  };

  const getCurrentUserId = () => {
    const user = JSON.parse(localStorage.getItem("user") || "{}");
    return user.id;
  };

  const getRoleColor = (role: string) => {
    switch (role.toLowerCase()) {
      case "student":
        return "text-blue-600";
      case "professor":
        return "text-green-600";
      case "alumni":
        return "text-purple-600";
      case "management":
        return "text-red-600";
      default:
        return "text-gray-600";
    }
  };

  const formatTime = (timestamp: string) => {
    const date = new Date(timestamp);
    const now = new Date();
    const diffInHours = (now.getTime() - date.getTime()) / (1000 * 60 * 60);

    if (diffInHours < 24) {
      return date.toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
      });
    } else if (diffInHours < 168) {
      // 7 days
      return date.toLocaleDateString([], { weekday: "short" });
    } else {
      return date.toLocaleDateString([], { month: "short", day: "numeric" });
    }
  };

  return (
    <div className="space-y-6">
      {/* Enhanced Header Section */}
      <div className="bg-gradient-to-r from-teal-50 to-cyan-50 rounded-3xl p-6 border border-teal-100">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="w-12 h-12 bg-gradient-to-r from-teal-400 to-cyan-500 rounded-2xl flex items-center justify-center shadow-lg">
              <MessageCircle className="h-6 w-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-800">Messages</h2>
              <p className="text-teal-600 font-medium">
                Connect with students, alumni, and faculty
              </p>
            </div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-teal-600">
              {conversations.length}
            </div>
            <div className="text-sm text-gray-600">Active Chats</div>
          </div>
        </div>
      </div>

      {/* Enhanced Chat Interface */}
      <div className="bg-white rounded-3xl shadow-lg border border-gray-100 overflow-hidden">
        <div className="grid grid-cols-1 lg:grid-cols-3 h-[600px]">
          {/* Enhanced Conversations Sidebar */}
          <div className="lg:col-span-1 bg-gradient-to-b from-gray-50 to-white border-r border-gray-200 flex flex-col">
            {/* Enhanced Search and Filter Header */}
            <div className="p-6 border-b border-gray-200">
              <div className="space-y-4">
                {/* New Chat Button */}
                <div className="relative" ref={dropdownRef}>
                  <button
                    onClick={() => setShowUserDropdown(!showUserDropdown)}
                    className="w-full bg-gradient-to-r from-teal-500 to-cyan-500 hover:from-teal-600 hover:to-cyan-600 text-white px-6 py-3 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 flex items-center justify-center space-x-3 font-semibold"
                  >
                    <Users className="h-5 w-5" />
                    <span>Start New Chat</span>
                    <ChevronDown className="h-5 w-5" />
                  </button>

                  {/* User Dropdown */}
                  {showUserDropdown && (
                    <div className="absolute top-full left-0 right-0 mt-1 bg-white backdrop-blur-sm border border-gray-200 rounded-xl shadow-lg z-50 max-h-80 overflow-hidden">
                      {/* Search and Filter */}
                      <div className="p-3 border-b border-gray-200 space-y-2">
                        <input
                          type="text"
                          value={searchQuery}
                          onChange={(e) => setSearchQuery(e.target.value)}
                          placeholder={
                            isSearching
                              ? "Searching..."
                              : "Search by name, email, or phone..."
                          }
                          className="w-full px-3 py-2 bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
                          disabled={isSearching}
                        />

                        <div className="flex space-x-1">
                          {[
                            "all",
                            "student",
                            "professor",
                            "alumni",
                            "management",
                          ].map((filter) => (
                            <button
                              key={filter}
                              onClick={() => setSelectedFilter(filter)}
                              className={`px-2 py-1 rounded text-xs font-medium transition-colors ${
                                selectedFilter === filter
                                  ? "bg-blue-600 text-white"
                                  : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                              }`}
                            >
                              {filter.charAt(0).toUpperCase() + filter.slice(1)}
                            </button>
                          ))}
                        </div>
                      </div>

                      {/* Users List */}
                      <div className="max-h-60 overflow-y-auto">
                        {isSearching ? (
                          <div className="p-4 text-center text-gray-500 text-sm">
                            <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600 mx-auto mb-2"></div>
                            Searching users...
                          </div>
                        ) : filteredUsers.length === 0 ? (
                          <div className="p-4 text-center text-gray-500 text-sm">
                            {searchQuery.trim()
                              ? `No users found for "${searchQuery}"`
                              : "No users found"}
                            <div className="text-xs text-gray-400 mt-1">
                              Try searching by name, email, or phone number
                            </div>
                          </div>
                        ) : (
                          filteredUsers.map((user) => (
                            <button
                              key={user.id}
                              onClick={() => selectUser(user)}
                              className="w-full text-left p-3 hover:bg-gray-50 transition-colors border-b border-gray-100 last:border-b-0"
                            >
                              <div className="flex items-center space-x-3">
                                <div className="w-8 h-8 bg-gray-600 rounded-full flex items-center justify-center flex-shrink-0">
                                  <User className="h-4 w-4 text-white" />
                                </div>
                                <div className="flex-1 min-w-0">
                                  <p className="font-medium text-sm truncate">
                                    {user.name}
                                  </p>
                                  <p className="text-xs text-gray-500 truncate">
                                    {user.email}
                                  </p>
                                  <p
                                    className={`text-xs font-medium ${getRoleColor(
                                      user.role
                                    )}`}
                                  >
                                    {user.role} • {user.department}
                                  </p>
                                </div>
                              </div>
                            </button>
                          ))
                        )}
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* Conversations List */}
            <div className="flex-1 overflow-y-auto">
              {conversations.length === 0 ? (
                <div className="p-6 text-center text-gray-500">
                  <MessageCircle className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                  <p className="text-sm font-medium">No conversations yet</p>
                  <p className="text-xs text-gray-400 mt-1">
                    Start a new chat to begin
                  </p>
                </div>
              ) : (
                <div className="space-y-1 p-2">
                  {conversations.map((conversation) => (
                    <button
                      key={conversation.user.id}
                      onClick={() => selectUser(conversation.user)}
                      className={`w-full text-left p-3 rounded-lg transition-colors ${
                        selectedUser?.id === conversation.user.id
                          ? "bg-blue-50 border border-blue-200"
                          : "hover:bg-gray-50"
                      }`}
                    >
                      <div className="flex items-center space-x-3">
                        <div className="relative">
                          <div className="w-10 h-10 bg-gray-600 rounded-full flex items-center justify-center">
                            <User className="h-5 w-5 text-white" />
                          </div>
                          {conversation.unreadCount > 0 && (
                            <div className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 text-white rounded-full flex items-center justify-center text-xs font-medium">
                              {conversation.unreadCount > 9
                                ? "9+"
                                : conversation.unreadCount}
                            </div>
                          )}
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center justify-between">
                            <p className="font-medium text-sm truncate">
                              {conversation.user.name}
                            </p>
                            {conversation.lastMessage && (
                              <p className="text-xs text-gray-500">
                                {formatTime(conversation.lastMessage.timestamp)}
                              </p>
                            )}
                          </div>
                          <p
                            className={`text-xs ${getRoleColor(
                              conversation.user.role
                            )}`}
                          >
                            {conversation.user.role}
                          </p>
                          {conversation.lastMessage && (
                            <p className="text-xs text-gray-500 truncate mt-1">
                              {conversation.lastMessage.message}
                            </p>
                          )}
                        </div>
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Chat Panel */}
          <div className="lg:col-span-2">
            {selectedUser ? (
              <div className="bg-white flex flex-col h-full">
                {/* Chat Header */}
                <div className="p-4 border-b border-gray-200 bg-gradient-to-r from-teal-50 to-cyan-50">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-gradient-to-r from-teal-400 to-cyan-500 rounded-full flex items-center justify-center">
                      <User className="h-6 w-6 text-white" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="font-semibold text-gray-800 truncate">
                        {selectedUser.name}
                      </h3>
                      <p className="text-sm text-gray-600 truncate">
                        {selectedUser.email}
                      </p>
                      <p
                        className={`text-xs font-medium truncate ${getRoleColor(
                          selectedUser.role
                        )}`}
                      >
                        {selectedUser.role} • {selectedUser.department}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Messages */}
                <div
                  className="flex-1 overflow-y-auto p-4 space-y-3"
                  style={{ maxHeight: "calc(500px - 120px)" }}
                >
                  {messages.length === 0 ? (
                    <div className="text-center text-gray-500 mt-6">
                      <MessageCircle className="h-10 w-10 mx-auto mb-3 text-gray-300" />
                      <p className="text-sm">
                        No messages yet. Start the conversation!
                      </p>
                    </div>
                  ) : (
                    messages.map((message) => {
                      const isCurrentUser =
                        message.senderId === getCurrentUserId();
                      return (
                        <div
                          key={message.id}
                          className={`flex ${
                            isCurrentUser ? "justify-end" : "justify-start"
                          }`}
                        >
                          <div
                            className={`flex items-start space-x-2 max-w-[70%] ${
                              isCurrentUser
                                ? "flex-row-reverse space-x-reverse"
                                : ""
                            }`}
                          >
                            <div
                              className={`w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 ${
                                isCurrentUser ? "bg-teal-500" : "bg-gray-500"
                              }`}
                            >
                              <User className="h-3 w-3 text-white" />
                            </div>
                            <div
                              className={`rounded-lg p-3 break-words ${
                                isCurrentUser
                                  ? "bg-gradient-to-r from-teal-500 to-cyan-500 text-white"
                                  : "bg-gray-100 text-gray-900"
                              }`}
                            >
                              <p className="text-sm break-words">
                                {message.message}
                              </p>
                              <p
                                className={`text-xs mt-1 opacity-70 ${
                                  isCurrentUser
                                    ? "text-teal-100"
                                    : "text-gray-500"
                                }`}
                              >
                                {formatTime(message.timestamp)}
                              </p>
                            </div>
                          </div>
                        </div>
                      );
                    })
                  )}
                  <div ref={messagesEndRef} />
                </div>

                {/* Input */}
                <div className="p-4 border-t border-gray-200 bg-gray-50">
                  <form onSubmit={sendMessage} className="flex space-x-3">
                    <input
                      type="text"
                      value={newMessage}
                      onChange={(e) => setNewMessage(e.target.value)}
                      placeholder="Type your message..."
                      className="flex-1 p-3 bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
                      disabled={loading}
                    />
                    <button
                      type="submit"
                      disabled={loading || !newMessage.trim()}
                      className="bg-gradient-to-r from-teal-500 to-cyan-500 hover:from-teal-600 hover:to-cyan-600 text-white p-3 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 shadow-lg hover:shadow-xl"
                    >
                      <Send className="h-5 w-5" />
                    </button>
                  </form>
                </div>
              </div>
            ) : (
              <div className="bg-gradient-to-br from-teal-50 to-cyan-50 p-8 text-center h-full flex items-center justify-center">
                <div>
                  <MessageCircle className="h-16 w-16 text-teal-300 mx-auto mb-4" />
                  <h3 className="text-lg font-medium text-gray-800 mb-2">
                    Select a Conversation
                  </h3>
                  <p className="text-teal-600">
                    Choose a conversation from the sidebar or start a new chat.
                  </p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
});

export default UserChat;
