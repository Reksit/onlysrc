import {
  Briefcase,
  Calendar,
  GraduationCap,
  Heart,
  Lock,
  LogOut,
  MessageSquare,
  Plus,
  TrendingUp,
  User,
  UserCheck,
  Users,
} from "lucide-react";
import React, { useEffect, useState } from "react";
import { useAuth } from "../../contexts/AuthContext";
import { useToast } from "../../contexts/ToastContext";
import { alumniAPI } from "../../services/api";
import AlumniDirectoryNew from "../features/AlumniDirectoryNew";
import AlumniEventRequest from "../features/AlumniEventRequest";
import AlumniManagementRequests from "../features/AlumniManagementRequests";
import AlumniProfileNew from "../features/AlumniProfileNew";
import ConnectionRequests from "../features/ConnectionRequests";
import EventsDashboard from "../features/EventsDashboard";
import EventsView from "../features/EventsView";
import JobBoardFixed from "../features/JobBoardFixed";
import PasswordChange from "../features/PasswordChange";
import UserChat from "../features/UserChat";

interface AlumniStats {
  networkConnections: number;
  eventsCount: number;
  jobsPosted: number;
}

const AlumniDashboard: React.FC = () => {
  const [activeTab, setActiveTab] = useState("dashboard");
  const [stats, setStats] = useState<AlumniStats>({
    networkConnections: 0,
    eventsCount: 0,
    jobsPosted: 0,
  });
  const [loading, setLoading] = useState(true);
  const [profileMenuOpen, setProfileMenuOpen] = useState(false);
  const [activeProfileTab, setActiveProfileTab] = useState("profile");
  const { showToast } = useToast();
  const { user, logout } = useAuth();

  useEffect(() => {
    loadStats();

    // Listen for connection updates to refresh stats
    const handleConnectionUpdate = () => {
      loadStats(true);
    };

    // Listen for job updates to refresh stats
    const handleJobUpdate = () => {
      loadStats(true);
    };

    window.addEventListener("connectionUpdated", handleConnectionUpdate);
    window.addEventListener("jobUpdated", handleJobUpdate);

    return () => {
      window.removeEventListener("connectionUpdated", handleConnectionUpdate);
      window.removeEventListener("jobUpdated", handleJobUpdate);
    };
  }, []);

  const loadStats = async (isRefresh = false) => {
    try {
      if (isRefresh) {
        setLoading(true);
      } else {
        setLoading(true);
      }
      const response = await alumniAPI.getAlumniStats();
      setStats(response);

      if (isRefresh) {
        showToast("Statistics refreshed successfully", "success");
      }
    } catch (error: any) {
      console.error("Failed to load alumni stats:", error);

      if (isRefresh) {
        showToast("Failed to refresh statistics", "error");
      }
    } finally {
      setLoading(false);
    }
  };

  const mainTabs = [
    { id: "dashboard", name: "Dashboard", icon: User },
    { id: "profile", name: "Profile", icon: User },
    { id: "directory", name: "Alumni Directory", icon: Users },
    { id: "connections", name: "Connections", icon: UserCheck },
    { id: "chat", name: "Messages", icon: MessageSquare },
  ];

  const professionalTabs = [
    { id: "jobs", name: "Job Board", icon: Briefcase },
    { id: "events", name: "Events", icon: Calendar },
    { id: "request-event", name: "Request Event", icon: Plus },
  ];

  const managementTabs = [
    {
      id: "alumni-managment-requests",
      name: "Alumni Requests",
      icon: GraduationCap,
    },
  ];

  const renderActiveComponent = () => {
    if (loading && activeTab !== "dashboard") {
      return (
        <div className="flex flex-col items-center justify-center py-16">
          <div className="relative">
            <div className="w-16 h-16 border-4 border-purple-200 border-t-purple-600 rounded-full animate-spin"></div>
          </div>
          <p className="mt-4 text-lg font-medium text-gray-700">Loading...</p>
        </div>
      );
    }

    switch (activeTab) {
      case "dashboard":
        return null; // Dashboard content is rendered in main area
      case "profile":
        return (
          <div className="space-y-6">
            {/* Profile Navigation */}
            <div className="bg-gradient-to-r from-purple-50 to-purple-100 rounded-xl p-4">
              <div className="flex items-center space-x-4">
                <button
                  onClick={() => setActiveProfileTab("profile")}
                  className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                    activeProfileTab === "profile"
                      ? "bg-white text-purple-700 shadow-sm"
                      : "text-purple-600 hover:bg-white/50"
                  }`}
                >
                  My Profile
                </button>
                <button
                  onClick={() => setActiveProfileTab("security")}
                  className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                    activeProfileTab === "security"
                      ? "bg-white text-purple-700 shadow-sm"
                      : "text-purple-600 hover:bg-white/50"
                  }`}
                >
                  Security Settings
                </button>
              </div>
            </div>

            {/* Profile Content */}
            {activeProfileTab === "profile" ? (
              <AlumniProfileNew />
            ) : (
              <div className="space-y-6">
                <div className="text-center py-8">
                  <Lock className="mx-auto h-12 w-12 text-gray-400 mb-4" />
                  <h3 className="text-lg font-medium text-gray-900 mb-2">
                    Security Settings
                  </h3>
                  <p className="text-gray-600 mb-6">
                    Manage your account security and password settings.
                  </p>
                </div>
                <div className="max-w-2xl mx-auto">
                  <PasswordChange />
                </div>
              </div>
            )}
          </div>
        );
      case "directory":
        return <AlumniDirectoryNew />;
      case "connections":
        return <ConnectionRequests />;
      case "jobs":
        return <JobBoardFixed />;
      case "events":
        return <EventsView />;
      case "request-event":
        return <AlumniEventRequest />;
      case "alumni-managment-requests":
        return <AlumniManagementRequests />;
      case "chat":
        return <UserChat />;
      default:
        return null;
    }
  };

  const CircularProgress = ({
    percentage,
    color,
  }: {
    percentage: number;
    color: string;
  }) => {
    const circumference = 2 * Math.PI * 45;
    const strokeDasharray = circumference;
    const strokeDashoffset = circumference - (percentage / 100) * circumference;

    return (
      <div className="relative w-24 h-24">
        <svg className="w-24 h-24 transform -rotate-90" viewBox="0 0 100 100">
          <circle
            cx="50"
            cy="50"
            r="45"
            stroke="#e5e7eb"
            strokeWidth="8"
            fill="none"
          />
          <circle
            cx="50"
            cy="50"
            r="45"
            stroke={color}
            strokeWidth="8"
            fill="none"
            strokeDasharray={strokeDasharray}
            strokeDashoffset={strokeDashoffset}
            strokeLinecap="round"
            className="transition-all duration-300"
          />
        </svg>
        <div className="absolute inset-0 flex items-center justify-center">
          <span className="text-lg font-bold text-gray-700">{percentage}%</span>
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Sidebar */}
      <div className="w-64 bg-gradient-to-b from-purple-400 to-purple-600 text-white flex flex-col">
        {/* Logo/Brand */}
        <div className="p-6 border-b border-purple-300/20">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-white rounded-lg flex items-center justify-center">
              <Heart className="h-6 w-6 text-purple-500" />
            </div>
            <div>
              <h1 className="text-lg font-bold">Alumni Network</h1>
            </div>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-4 overflow-y-auto">
          {/* Main Section */}
          <div className="mb-6">
            <div className="text-xs font-semibold text-purple-200 uppercase tracking-wide mb-3 px-3">
              Main
            </div>
            <div className="space-y-1">
              {mainTabs.map((tab) => {
                const Icon = tab.icon;
                const isActive = activeTab === tab.id;
                return (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`w-full flex items-center space-x-3 px-3 py-2.5 rounded-lg text-left transition-all duration-200 text-sm ${
                      isActive
                        ? "bg-white text-purple-700 shadow-lg font-medium"
                        : "text-purple-100 hover:bg-purple-300/20 hover:text-white"
                    }`}
                  >
                    <Icon className="h-4 w-4 flex-shrink-0" />
                    <span className="truncate">{tab.name}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Professional Section */}
          <div className="mb-6">
            <div className="text-xs font-semibold text-purple-200 uppercase tracking-wide mb-3 px-3">
              Professional
            </div>
            <div className="space-y-1">
              {professionalTabs.map((tab) => {
                const Icon = tab.icon;
                const isActive = activeTab === tab.id;
                return (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`w-full flex items-center space-x-3 px-3 py-2.5 rounded-lg text-left transition-all duration-200 text-sm ${
                      isActive
                        ? "bg-white text-purple-700 shadow-lg font-medium"
                        : "text-purple-100 hover:bg-purple-300/20 hover:text-white"
                    }`}
                  >
                    <Icon className="h-4 w-4 flex-shrink-0" />
                    <span className="truncate">{tab.name}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Management Section */}
          <div>
            <div className="text-xs font-semibold text-purple-200 uppercase tracking-wide mb-3 px-3">
              Management
            </div>
            <div className="space-y-1">
              {managementTabs.map((tab) => {
                const Icon = tab.icon;
                const isActive = activeTab === tab.id;
                return (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`w-full flex items-center space-x-3 px-3 py-2.5 rounded-lg text-left transition-all duration-200 text-sm ${
                      isActive
                        ? "bg-white text-purple-700 shadow-lg font-medium"
                        : "text-purple-100 hover:bg-purple-300/20 hover:text-white"
                    }`}
                  >
                    <Icon className="h-4 w-4 flex-shrink-0" />
                    <span className="truncate">{tab.name}</span>
                  </button>
                );
              })}
            </div>
          </div>
        </nav>

        {/* User Profile in Sidebar */}
        <div className="p-4 border-t border-purple-300/20">
          <div className="relative">
            <button
              onClick={() => setProfileMenuOpen(!profileMenuOpen)}
              className="w-full flex items-center space-x-3 p-3 rounded-lg hover:bg-purple-300/20 transition-colors"
            >
              <div className="w-10 h-10 bg-gradient-to-br from-purple-300 to-purple-500 rounded-full flex items-center justify-center">
                <User className="h-5 w-5 text-white" />
              </div>
              <div className="flex-1 text-left">
                <div className="font-medium text-white truncate">
                  {user?.name}
                </div>
                <div className="text-sm text-purple-200">Alumni</div>
              </div>
            </button>

            {profileMenuOpen && (
              <div className="absolute bottom-full left-0 right-0 mb-2 bg-white rounded-lg shadow-xl border border-gray-200 py-2">
                <button
                  onClick={() => {
                    setActiveTab("profile");
                    setActiveProfileTab("profile");
                    setProfileMenuOpen(false);
                  }}
                  className="w-full flex items-center space-x-3 px-4 py-2 text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  <User className="h-4 w-4" />
                  <span className="text-sm">View Profile</span>
                </button>
                <button
                  onClick={() => {
                    setActiveTab("profile");
                    setActiveProfileTab("security");
                    setProfileMenuOpen(false);
                  }}
                  className="w-full flex items-center space-x-3 px-4 py-2 text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  <Lock className="h-4 w-4" />
                  <span className="text-sm">Security Settings</span>
                </button>
                <div className="border-t border-gray-200 mt-2 pt-2">
                  <button
                    onClick={() => logout()}
                    className="w-full flex items-center space-x-3 px-4 py-2 text-red-600 hover:bg-red-50 transition-colors"
                  >
                    <LogOut className="h-4 w-4" />
                    <span className="text-sm">Sign Out</span>
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Sidebar Footer with Visual Indicator */}
        <div className="p-4">
          <div className="flex justify-center">
            <div className="w-16 h-16 bg-white/10 rounded-full flex items-center justify-center">
              <div className="w-8 h-8 bg-white/20 rounded-full"></div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col">
        {/* Header */}
        <header className="bg-white border-b border-gray-200 px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              {/* Search input removed */}
            </div>

            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2 text-sm text-gray-600">
                <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                <span>Active Status</span>
              </div>
              {/* Profile icon and logout button removed */}
            </div>
          </div>
        </header>

        {/* Main Content Area */}
        <main className="flex-1 p-6 bg-gray-50">
          {activeTab === "dashboard" ? (
            <div className="space-y-6">
              {/* University Info Card */}
              <div className="bg-gradient-to-r from-white to-purple-50 rounded-xl p-6 shadow-sm border border-gray-200">
                <div className="flex items-center justify-between">
                  <div className="flex-1">
                    <div className="flex items-center space-x-3 mb-3">
                      <div className="w-12 h-12 bg-gradient-to-br from-purple-400 to-purple-600 rounded-lg flex items-center justify-center">
                        <GraduationCap className="h-6 w-6 text-white" />
                      </div>
                      <div>
                        <h2 className="text-2xl font-bold text-gray-900">
                          {user?.name || "Alumni"} Dashboard
                        </h2>
                        <p className="text-gray-600">
                          Computer Science Alumni • Class of 2020 • Professional
                          Network
                        </p>
                      </div>
                    </div>
                    <div className="grid grid-cols-3 gap-6 mt-6">
                      <div className="text-center p-4 bg-white rounded-lg shadow-sm">
                        <div className="text-3xl font-bold text-purple-600 mb-1">
                          {stats.networkConnections}
                        </div>
                        <div className="text-sm text-gray-500 font-medium">
                          Network Connections
                        </div>
                      </div>
                      <div className="text-center p-4 bg-white rounded-lg shadow-sm">
                        <div className="text-3xl font-bold text-green-600 mb-1">
                          {stats.eventsCount}
                        </div>
                        <div className="text-sm text-gray-500 font-medium">
                          Events Attended
                        </div>
                      </div>
                      <div className="text-center p-4 bg-white rounded-lg shadow-sm">
                        <div className="text-3xl font-bold text-blue-600 mb-1">
                          {stats.jobsPosted}
                        </div>
                        <div className="text-sm text-gray-500 font-medium">
                          Opportunities Shared
                        </div>
                      </div>
                    </div>
                  </div>
                  {/* Refresh button removed */}
                </div>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Analytics Section */}
                <div className="lg:col-span-2 space-y-6">
                  {/* Upcoming Events */}
                  <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                    <div className="flex items-center justify-between mb-6">
                      <h3 className="text-lg font-semibold text-gray-900">
                        Upcoming Events
                      </h3>
                      <button
                        onClick={() => setActiveTab("events")}
                        className="text-sm text-purple-600 hover:text-purple-700 font-medium"
                      >
                        View All Events →
                      </button>
                    </div>
                    <EventsDashboard />
                  </div>

                  {/* Professional Metrics */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                      <div className="flex items-center justify-between mb-4">
                        <h3 className="text-lg font-semibold text-gray-900">
                          Career Impact
                        </h3>
                        <div className="flex items-center space-x-2">
                          <TrendingUp className="h-5 w-5 text-green-500" />
                          <span className="text-2xl font-bold text-gray-900">
                            {stats.jobsPosted + stats.networkConnections}
                          </span>
                        </div>
                      </div>
                      <p className="text-sm text-gray-600 mb-4">
                        total contributions
                      </p>
                      <div className="flex items-center justify-between text-sm">
                        <span className="text-gray-600">This Quarter</span>
                        <span className="text-green-600 font-medium">
                          +{stats.jobsPosted * 2}%
                        </span>
                      </div>
                    </div>

                    <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                      <h3 className="text-lg font-semibold text-gray-900 mb-4">
                        Alumni Engagement
                      </h3>
                      <div className="flex items-center justify-between mb-4">
                        <div>
                          <div className="flex items-center space-x-2 mb-2">
                            <div className="w-3 h-3 bg-purple-500 rounded-full"></div>
                            <span className="text-sm text-gray-600">
                              Active Alumni
                            </span>
                          </div>
                          <div className="text-2xl font-bold text-gray-900">
                            {Math.min(
                              Math.round(
                                (stats.networkConnections /
                                  (stats.networkConnections + 20)) *
                                  100
                              ),
                              95
                            )}
                            %
                          </div>
                        </div>
                        <CircularProgress
                          percentage={Math.min(
                            Math.round(
                              (stats.networkConnections /
                                (stats.networkConnections + 20)) *
                                100
                            ),
                            95
                          )}
                          color="#a855f7"
                        />
                      </div>
                      <div className="flex items-center space-x-2">
                        <div className="w-3 h-3 bg-green-500 rounded-full"></div>
                        <span className="text-sm text-gray-600">
                          New Graduates
                        </span>
                        <span className="text-lg font-bold text-gray-900 ml-auto">
                          {Math.max(
                            100 -
                              Math.round(
                                (stats.networkConnections /
                                  (stats.networkConnections + 20)) *
                                  100
                              ),
                            5
                          )}
                          %
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Right Sidebar */}
                <div className="space-y-6">
                  {/* Profile Card */}
                  <div className="bg-gradient-to-br from-purple-400 to-purple-600 rounded-xl p-6 text-white">
                    <div className="flex items-center justify-between mb-4">
                      <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
                        <User className="h-6 w-6 text-white" />
                      </div>
                      {/* Refresh button removed */}
                    </div>
                    <div className="mb-4">
                      <h3 className="text-lg font-bold">{user?.name}</h3>
                      <p className="text-purple-100">Alumni Network Member</p>
                    </div>
                    <button
                      onClick={() => setActiveTab("profile")}
                      className="w-full bg-white/20 hover:bg-white/30 text-white font-medium py-2 px-4 rounded-lg transition-colors"
                    >
                      Manage Profile
                    </button>
                  </div>

                  {/* Alumni Network */}
                  <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                    <div className="flex items-center justify-between mb-4">
                      <h3 className="text-lg font-semibold text-gray-900">
                        Your Network
                      </h3>
                      <button
                        onClick={() => setActiveTab("connections")}
                        className="text-sm text-purple-600 hover:text-purple-700 font-medium"
                      >
                        View All
                      </button>
                    </div>
                    <div className="space-y-3">
                      {/* Real network preview */}
                      <div className="flex items-center space-x-3 p-2 rounded-lg hover:bg-gray-50">
                        <div className="w-10 h-10 bg-gradient-to-br from-blue-400 to-blue-500 rounded-full flex items-center justify-center">
                          <User className="h-5 w-5 text-white" />
                        </div>
                        <div className="flex-1">
                          <div className="font-medium text-gray-900">
                            Recent Connection
                          </div>
                          <div className="text-sm text-gray-500">
                            Software Engineer at Tech Corp
                          </div>
                        </div>
                      </div>
                      <div className="flex items-center space-x-3 p-2 rounded-lg hover:bg-gray-50">
                        <div className="w-10 h-10 bg-gradient-to-br from-green-400 to-green-500 rounded-full flex items-center justify-center">
                          <Users className="h-5 w-5 text-white" />
                        </div>
                        <div className="flex-1">
                          <div className="font-medium text-gray-900">
                            {stats.networkConnections} Total Connections
                          </div>
                          <div className="text-sm text-gray-500">
                            Active in your network
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Quick Actions */}
                  <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                    <h3 className="text-lg font-semibold text-gray-900 mb-4">
                      Quick Actions
                    </h3>
                    <div className="space-y-3">
                      <button
                        onClick={() => setActiveTab("jobs")}
                        className="w-full flex items-center space-x-3 p-3 text-left bg-purple-50 hover:bg-purple-100 rounded-lg transition-colors"
                      >
                        <div className="w-8 h-8 bg-purple-500 rounded-lg flex items-center justify-center">
                          <Briefcase className="h-4 w-4 text-white" />
                        </div>
                        <div>
                          <div className="font-medium text-gray-900">
                            Post Job Opening
                          </div>
                          <div className="text-sm text-gray-500">
                            Share opportunities
                          </div>
                        </div>
                      </button>
                      <button
                        onClick={() => setActiveTab("request-event")}
                        className="w-full flex items-center space-x-3 p-3 text-left bg-green-50 hover:bg-green-100 rounded-lg transition-colors"
                      >
                        <div className="w-8 h-8 bg-green-500 rounded-lg flex items-center justify-center">
                          <Calendar className="h-4 w-4 text-white" />
                        </div>
                        <div>
                          <div className="font-medium text-gray-900">
                            Request Event
                          </div>
                          <div className="text-sm text-gray-500">
                            Organize networking
                          </div>
                        </div>
                      </button>
                    </div>
                  </div>

                  {/* Professional Growth */}
                  <div className="bg-gradient-to-br from-purple-100 to-purple-200 rounded-xl p-6">
                    <div className="flex items-center space-x-3 mb-3">
                      <div className="w-8 h-8 bg-purple-500 rounded-lg flex items-center justify-center">
                        <TrendingUp className="h-4 w-4 text-white" />
                      </div>
                      <h3 className="text-lg font-semibold text-gray-900">
                        Professional Growth
                      </h3>
                    </div>
                    <p className="text-sm text-gray-600 mb-4">
                      Expand your network and enhance your career opportunities
                      through alumni connections.
                    </p>
                    <button
                      onClick={() => setActiveTab("directory")}
                      className="w-full bg-white hover:bg-gray-50 text-purple-700 font-medium py-2 px-4 rounded-lg transition-colors"
                    >
                      Explore Alumni Directory
                    </button>
                  </div>
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200 min-h-[600px]">
              {renderActiveComponent()}
            </div>
          )}
        </main>
      </div>
    </div>
  );
};

export default AlumniDashboard;
