import React, { useState } from "react";
import {
  MapPin,
  Clock,
  Footprints,
  Moon,
  Heart,
  ThumbsUp,
  Star,
  CheckCircle,
  Activity,
  MessageCircle,
  Calendar,
  Users,
  Sparkles,
  ArrowRight,
  Mountain,
  HeartHandshake,
  Car,
  ShoppingBag,
  Coffee,
  Utensils,
  Smartphone,
  BookOpen,
  Plus,
  Trash2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";

// ─── Mock Data ────────────────────────────────────────────────────────────────

const ACTIVITIES = [
  {
    id: 1,
    title: "Chair Yoga Session",
    subtitle: "Beginner friendly · Low impact",
    date: "Saturday",
    time: "9:00 AM",
    location: "Community Center",
    duration: "45 min",
    attendees: [
      { name: "Barbara", initials: "B", color: "bg-rose-100 text-rose-600" },
      { name: "Marcus", initials: "M", color: "bg-teal-100 text-teal-600" },
      { name: "Eleanor", initials: "E", color: "bg-violet-100 text-violet-600" },
      { name: "Ruth", initials: "R", color: "bg-amber-100 text-amber-600" },
    ],
    extraCount: 2,
    gradient: "from-violet-500 to-purple-600",
    iconEl: Activity,
    badge: "NOHA Recommends",
    badgeColor: "bg-teal-100 text-teal-700",
    highlighted: true,
  },
  {
    id: 2,
    title: "Neighborhood Walk",
    subtitle: "Easy pace · Riverside Path",
    date: "Sunday",
    time: "2:00 PM",
    location: "Riverside Park",
    duration: "45 min",
    attendees: [
      { name: "George", initials: "G", color: "bg-blue-100 text-blue-600" },
      { name: "Frances", initials: "F", color: "bg-purple-100 text-purple-600" },
    ],
    extraCount: 2,
    gradient: "from-teal-500 to-cyan-600",
    iconEl: Footprints,
    badge: null,
    badgeColor: null,
    highlighted: false,
  },
  {
    id: 3,
    title: "Meditation Circle",
    subtitle: "Online or in-person",
    date: "Tuesday",
    time: "10:00 AM",
    location: "Community Center / Zoom",
    duration: "30 min",
    attendees: [
      { name: "Dorothy", initials: "D", color: "bg-pink-100 text-pink-600" },
      { name: "Harold", initials: "H", color: "bg-amber-100 text-amber-600" },
      { name: "Margaret", initials: "M", color: "bg-emerald-100 text-emerald-600" },
    ],
    extraCount: 5,
    gradient: "from-indigo-500 to-blue-600",
    iconEl: Sparkles,
    badge: null,
    badgeColor: null,
    highlighted: false,
  },
  {
    id: 4,
    title: "Nature Hiking Trip",
    subtitle: "Moderate trail · Group outing",
    date: "Next Friday",
    time: "9:00 AM",
    location: "City Nature Reserve",
    duration: "2 hrs",
    attendees: [
      { name: "Robert", initials: "R", color: "bg-teal-100 text-teal-600" },
    ],
    extraCount: 10,
    gradient: "from-emerald-500 to-green-600",
    iconEl: Mountain,
    badge: "Spots available",
    badgeColor: "bg-emerald-100 text-emerald-700",
    highlighted: false,
  },
  {
    id: 5,
    title: "Card Games Afternoon",
    subtitle: "Bridge, Rummy & more · All welcome",
    date: "Wednesday",
    time: "2:00 PM",
    location: "Senior Lounge, Rm 4",
    duration: "2 hrs",
    attendees: [
      { name: "Ruth", initials: "R", color: "bg-amber-100 text-amber-600" },
      { name: "Harold", initials: "H", color: "bg-amber-100 text-amber-600" },
      { name: "Frances", initials: "F", color: "bg-purple-100 text-purple-600" },
    ],
    extraCount: 3,
    gradient: "from-orange-400 to-amber-500",
    iconEl: Star,
    badge: "Weekly favourite",
    badgeColor: "bg-amber-100 text-amber-700",
    highlighted: false,
  },
  {
    id: 6,
    title: "Memory & Storytelling",
    subtitle: "Share stories · Build connections",
    date: "Thursday",
    time: "11:00 AM",
    location: "Community Center, Hall B",
    duration: "1 hr",
    attendees: [
      { name: "Margaret", initials: "M", color: "bg-emerald-100 text-emerald-600" },
      { name: "Dorothy", initials: "D", color: "bg-pink-100 text-pink-600" },
    ],
    extraCount: 4,
    gradient: "from-rose-400 to-pink-500",
    iconEl: MessageCircle,
    badge: "New session",
    badgeColor: "bg-rose-100 text-rose-700",
    highlighted: false,
  },
];

const FEED_ITEMS = [
  {
    id: 1,
    name: "Barbara",
    initials: "B",
    color: "bg-rose-100 text-rose-600",
    activity: "completed her morning walk — 2,100 steps before breakfast!",
    time: "32 min ago",
    iconEl: Footprints,
    iconColor: "text-teal-500",
    bgColor: "bg-teal-50",
  },
  {
    id: 2,
    name: "Marcus",
    initials: "M",
    color: "bg-teal-100 text-teal-600",
    activity: "had a great night of sleep — 7.5 hours, score 88.",
    time: "1 hr ago",
    iconEl: Moon,
    iconColor: "text-violet-500",
    bgColor: "bg-violet-50",
  },
  {
    id: 3,
    name: "Eleanor",
    initials: "E",
    color: "bg-violet-100 text-violet-600",
    activity: 'signed up for Saturday\'s Chair Yoga. "See you there!"',
    time: "2 hrs ago",
    iconEl: Star,
    iconColor: "text-amber-500",
    bgColor: "bg-amber-50",
  },
  {
    id: 4,
    name: "Harold",
    initials: "H",
    color: "bg-amber-100 text-amber-600",
    activity: "stayed well hydrated all day — 8 cups logged.",
    time: "3 hrs ago",
    iconEl: Heart,
    iconColor: "text-rose-500",
    bgColor: "bg-rose-50",
  },
  {
    id: 5,
    name: "Dorothy",
    initials: "D",
    color: "bg-pink-100 text-pink-600",
    activity: "joined the Tuesday Meditation Circle.",
    time: "4 hrs ago",
    iconEl: MessageCircle,
    iconColor: "text-indigo-500",
    bgColor: "bg-indigo-50",
  },
];

const HELP_POSTS: {
  id: number;
  type: "request" | "offer";
  name: string;
  initials: string;
  color: string;
  message: string;
  date: string;
  time: string;
  category: string;
  categoryIcon: React.ElementType;
  categoryColor: string;
}[] = [
  { id: 1,   type: "request", name: "Margaret", initials: "M", color: "bg-violet-100 text-violet-600",
    message: "Could use a ride to my eye doctor this Thursday at 2pm — Oak Street Clinic.",
    date: "Mon, Feb 24",  time: "9:12 AM",  category: "Ride",          categoryIcon: Car,         categoryColor: "bg-blue-100 text-blue-700" },
  { id: 101, type: "offer",   name: "Barbara",  initials: "B", color: "bg-rose-100 text-rose-600",
    message: "Happy to give rides Tues & Thurs — I pass right by the clinic and pharmacy.",
    date: "Mon, Feb 24",  time: "8:45 AM",  category: "Ride",          categoryIcon: Car,         categoryColor: "bg-blue-100 text-blue-700" },
  { id: 2,   type: "request", name: "Harold",   initials: "H", color: "bg-amber-100 text-amber-600",
    message: "Looking for a walking buddy Mon & Wed mornings around 7am. Any takers?",
    date: "Mon, Feb 24",  time: "7:30 AM",  category: "Companionship", categoryIcon: Coffee,      categoryColor: "bg-amber-100 text-amber-700" },
  { id: 102, type: "offer",   name: "George",   initials: "G", color: "bg-blue-100 text-blue-600",
    message: "Made too much soup this weekend — happy to share with a neighbor!",
    date: "Mon, Feb 24",  time: "6:50 AM",  category: "Meal",          categoryIcon: Utensils,    categoryColor: "bg-orange-100 text-orange-700" },
  { id: 3,   type: "request", name: "Ruth",     initials: "R", color: "bg-pink-100 text-pink-600",
    message: "Need help carrying groceries up 3 flights — the elevator is broken this week.",
    date: "Sun, Feb 23",  time: "4:15 PM",  category: "Groceries",     categoryIcon: ShoppingBag, categoryColor: "bg-emerald-100 text-emerald-700" },
  { id: 103, type: "offer",   name: "Frances",  initials: "F", color: "bg-indigo-100 text-indigo-600",
    message: "Can help set up phones, tablets, or apps on weekends. Just knock or call!",
    date: "Sun, Feb 23",  time: "11:00 AM", category: "Tech Help",     categoryIcon: Smartphone,  categoryColor: "bg-indigo-100 text-indigo-700" },
  { id: 4,   type: "request", name: "Eleanor",  initials: "E", color: "bg-purple-100 text-purple-600",
    message: "Anyone have a good mystery novel to lend? I've finished mine.",
    date: "Sat, Feb 22",  time: "3:30 PM",  category: "Other",         categoryIcon: BookOpen,    categoryColor: "bg-gray-100 text-gray-600" },
  { id: 104, type: "offer",   name: "Dorothy",  initials: "D", color: "bg-pink-100 text-pink-600",
    message: "Free to chat over the phone any afternoon this week. Could use the company too!",
    date: "Sat, Feb 22",  time: "1:00 PM",  category: "Companionship", categoryIcon: Coffee,      categoryColor: "bg-amber-100 text-amber-700" },
];

// ─── Component ────────────────────────────────────────────────────────────────

export type CommunitySection = "all" | "activity" | "helping";

const FRANK = { name: "Frank", initials: "F", color: "bg-primary/15 text-primary" };

const CATEGORIES: { label: string; icon: React.ElementType; color: string }[] = [
  { label: "Ride",          icon: Car,         color: "bg-blue-100 text-blue-700" },
  { label: "Companionship", icon: Coffee,       color: "bg-amber-100 text-amber-700" },
  { label: "Meal",          icon: Utensils,     color: "bg-orange-100 text-orange-700" },
  { label: "Groceries",     icon: ShoppingBag,  color: "bg-emerald-100 text-emerald-700" },
  { label: "Tech Help",     icon: Smartphone,   color: "bg-indigo-100 text-indigo-700" },
  { label: "Other",         icon: BookOpen,     color: "bg-gray-100 text-gray-600" },
];

export function CommunityPanel({ section = "all" }: { section?: CommunitySection }) {
  const [joined, setJoined] = useState<Set<number>>(new Set());
  const [liked, setLiked] = useState<Set<number>>(new Set());
  const [helped, setHelped] = useState<Set<number>>(new Set());
  const [connected, setConnected] = useState<Set<number>>(new Set());

  // Post dialog state
  const [postOpen, setPostOpen] = useState(false);
  const [postType, setPostType] = useState<"request" | "offer">("request");
  const [postCategory, setPostCategory] = useState("Ride");
  const [postMessage, setPostMessage] = useState("");
  const [posts, setPosts] = useState(HELP_POSTS);

  const handleHelp = (id: number, name: string) => {
    setHelped((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
        toast.info(`Removed your offer to help ${name}.`);
      } else {
        next.add(id);
        toast.success(`${name} will be notified that you can help!`);
      }
      return next;
    });
  };

  const handleJoin = (id: number, title: string) => {
    setJoined((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
        toast.info(`Removed from ${title}`);
      } else {
        next.add(id);
        toast.success(`You're signed up for ${title}!`);
      }
      return next;
    });
  };

  const handleLike = (id: number) => {
    setLiked((prev) => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  };

  const handleDeletePost = (id: number) => {
    setPosts((prev) => prev.filter((p) => p.id !== id));
    toast.info("Your post has been removed.");
  };

  const handleSubmitPost = () => {
    if (!postMessage.trim()) return;
    const cat = CATEGORIES.find((c) => c.label === postCategory) ?? CATEGORIES[0];
    const now = new Date();
    const dateStr = now.toLocaleDateString("en-US", { weekday: "short", month: "short", day: "numeric" });
    const timeStr = now.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" });
    const newPost = {
      id: Date.now(),
      type: postType,
      name: FRANK.name,
      initials: FRANK.initials,
      color: FRANK.color,
      message: postMessage.trim(),
      date: dateStr,
      time: timeStr,
      category: cat.label,
      categoryIcon: cat.icon,
      categoryColor: cat.color,
    };
    setPosts((prev) => [newPost, ...prev]);
    toast.success("Your post is now on the board!");
    setPostMessage("");
    setPostType("request");
    setPostCategory("Ride");
    setPostOpen(false);
  };

  return (
    <div className="space-y-6">
      {/* ── Community Activities ─────────────────────────────────────────────── */}
      {(section === "all" || section === "activity") && <div>
        <div className="mb-4 flex items-center justify-between">
          <div>
            <h3 className="font-display text-heading text-foreground">Community Activities This Week</h3>
            <p className="mt-0.5 text-body-sm text-muted-foreground">
              Neighbors you know are already signed up
            </p>
          </div>
          <span className="flex items-center gap-1.5 rounded-full bg-muted px-3 py-1 text-caption text-muted-foreground">
            <Users className="h-3.5 w-3.5" />
            142 neighbors
          </span>
        </div>

        <div className="grid max-h-[520px] gap-4 overflow-y-auto pr-1 sm:grid-cols-2">
          {ACTIVITIES.map((act) => {
            const Icon = act.iconEl;
            const isJoined = joined.has(act.id);
            return (
              <div
                key={act.id}
                className={`overflow-hidden rounded-2xl shadow-card transition-all duration-300 hover:-translate-y-1 hover:shadow-glow ${
                  act.highlighted ? "ring-2 ring-primary/30" : ""
                }`}
              >
                {/* Gradient Header */}
                <div className={`flex items-center gap-3 bg-gradient-to-r ${act.gradient} px-5 py-4`}>
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white/20">
                    <Icon className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <p className="text-body font-semibold leading-tight text-white">{act.title}</p>
                    <p className="text-caption text-white/80">{act.subtitle}</p>
                  </div>
                </div>

                {/* Card Body */}
                <div className="bg-card p-5">
                  {/* Meta info */}
                  <div className="mb-4 space-y-1.5">
                    <div className="flex items-center gap-2 text-body-sm text-foreground">
                      <Calendar className="h-3.5 w-3.5 flex-shrink-0 text-muted-foreground" />
                      <span>
                        {act.date} · {act.time}
                      </span>
                    </div>
                    <div className="flex items-center gap-2 text-body-sm text-muted-foreground">
                      <MapPin className="h-3.5 w-3.5 flex-shrink-0" />
                      <span>{act.location}</span>
                    </div>
                    <div className="flex items-center gap-2 text-body-sm text-muted-foreground">
                      <Clock className="h-3.5 w-3.5 flex-shrink-0" />
                      <span>{act.duration}</span>
                    </div>
                  </div>

                  {/* Attendee Avatars */}
                  <div className="mb-4 flex items-center gap-2">
                    <div className="flex -space-x-2">
                      {act.attendees.slice(0, 3).map((a) => (
                        <div
                          key={a.name}
                          title={a.name}
                          className={`flex h-7 w-7 items-center justify-center rounded-full border-2 border-card text-caption font-semibold ${a.color}`}
                        >
                          {a.initials}
                        </div>
                      ))}
                      {act.extraCount > 0 && (
                        <div className="flex h-7 w-7 items-center justify-center rounded-full border-2 border-card bg-muted text-caption font-medium text-muted-foreground">
                          +{act.extraCount}
                        </div>
                      )}
                    </div>
                    <span className="text-caption text-muted-foreground">
                      {act.attendees[0]?.name}
                      {act.attendees.length > 1 ? ` & ${act.attendees.length - 1} more` : ""} going
                    </span>
                  </div>

                  {/* Footer */}
                  <div className="flex items-center justify-between">
                    {act.badge ? (
                      <span className={`rounded-full px-2.5 py-1 text-caption font-medium ${act.badgeColor}`}>
                        {act.badge}
                      </span>
                    ) : (
                      <span />
                    )}
                    <Button
                      size="sm"
                      variant={isJoined ? "outline" : "default"}
                      onClick={() => handleJoin(act.id, act.title)}
                      className="text-body-sm"
                    >
                      {isJoined ? (
                        <>
                          <CheckCircle className="mr-1.5 h-3.5 w-3.5" />
                          Joined
                        </>
                      ) : (
                        <>
                          Join
                          <ArrowRight className="ml-1.5 h-3.5 w-3.5" />
                        </>
                      )}
                    </Button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      }

      {/* ── Helping Hand Board ───────────────────────────────────────────────── */}
      {(section === "all" || section === "helping") && <div className="rounded-2xl bg-card p-6 shadow-card">
        {/* Header */}
        <div className="mb-5 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-rose-100">
              <HeartHandshake className="h-5 w-5 text-rose-500" />
            </div>
            <div>
              <h3 className="font-display text-heading text-foreground">Helping Hand Board</h3>
              <p className="text-caption text-muted-foreground">Neighbors supporting neighbors</p>
            </div>
          </div>
          <Button
            size="sm"
            variant="outline"
            onClick={() => setPostOpen(true)}
            className="text-body-sm"
          >
            <Plus className="mr-1.5 h-3.5 w-3.5" />
            Post
          </Button>
        </div>

        <div className="flex max-h-[520px] flex-col gap-4 overflow-y-auto pr-1">
          {posts.map((post) => {
            const CatIcon = post.categoryIcon;
            const isRequest = post.type === "request";
            const isHelping = helped.has(post.id);
            const isConnected = connected.has(post.id);
            const isMine = post.name === FRANK.name;
            return (
              <div
                key={post.id}
                className={`rounded-2xl border-2 p-5 ${
                  isRequest
                    ? "border-rose-100 bg-rose-50/30"
                    : "border-emerald-100 bg-emerald-50/30"
                }`}
              >
                {/* Avatar + name + type + delete */}
                <div className="mb-4 flex items-center gap-3">
                  <div
                    className={`flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-full text-body font-bold ${post.color}`}
                  >
                    {post.initials}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <p className="text-body font-semibold text-foreground">{post.name}</p>
                      <span
                        className={`rounded-full px-2.5 py-0.5 text-caption font-medium ${
                          isRequest
                            ? "bg-rose-100 text-rose-700"
                            : "bg-emerald-100 text-emerald-700"
                        }`}
                      >
                        {isRequest ? "Needs Help" : "Offering"}
                      </span>
                      {isMine && (
                        <span className="rounded-full bg-primary/10 px-2 py-0.5 text-caption font-medium text-primary">
                          You
                        </span>
                      )}
                    </div>
                    <div className="mt-0.5 flex items-center gap-1.5 text-body-sm text-muted-foreground">
                      <CatIcon className="h-3.5 w-3.5" />
                      <span>{post.category}</span>
                    </div>
                    <div className="mt-0.5 flex items-center gap-1 text-caption text-muted-foreground">
                      <Clock className="h-3 w-3" />
                      <span>{post.date} · {post.time}</span>
                    </div>
                  </div>
                  {isMine && (
                    <button
                      onClick={() => handleDeletePost(post.id)}
                      className="flex flex-shrink-0 items-center gap-1 text-caption text-muted-foreground transition-colors hover:text-destructive"
                    >
                      <Trash2 className="h-3.5 w-3.5" />
                      Delete
                    </button>
                  )}
                </div>

                {/* Message + Action side by side */}
                <div className={`flex items-center gap-4 ${isMine ? "" : ""}`}>
                  <p className="flex-1 text-body leading-relaxed text-foreground">
                    {post.message}
                  </p>
                  {!isMine && (
                    <Button
                      variant={(!isRequest && isConnected) || (isRequest && isHelping) ? "outline" : "default"}
                      onClick={() => {
                        if (isRequest) {
                          handleHelp(post.id, post.name);
                        } else {
                          setConnected((prev) => {
                            const next = new Set(prev);
                            if (next.has(post.id)) {
                              next.delete(post.id);
                              toast.info(`Disconnected from ${post.name}.`);
                            } else {
                              next.add(post.id);
                              toast.success(`Connected with ${post.name}!`);
                            }
                            return next;
                          });
                        }
                      }}
                      className="flex-shrink-0 h-14 px-8 text-body font-semibold"
                    >
                      {isRequest ? (
                        isHelping ? (
                          <><CheckCircle className="mr-2 h-6 w-6" /> Helping!</>
                        ) : (
                          <><HeartHandshake className="mr-2 h-6 w-6" /> I Can Help</>
                        )
                      ) : isConnected ? (
                        <><CheckCircle className="mr-2 h-6 w-6" /> Connected</>
                      ) : (
                        "Connect"
                      )}
                    </Button>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      }

      {/* ── Post Dialog ───────────────────────────────────────────────────────── */}
      {(section === "all" || section === "helping") && <Dialog open={postOpen} onOpenChange={setPostOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="font-display text-heading">Add to the Board</DialogTitle>
          </DialogHeader>

          {/* Frank identity */}
          <div className="flex items-center gap-3 rounded-xl bg-muted/50 px-4 py-3">
            <div className={`flex h-10 w-10 items-center justify-center rounded-full text-body font-bold ${FRANK.color}`}>
              {FRANK.initials}
            </div>
            <div>
              <p className="text-body font-semibold text-foreground">{FRANK.name}</p>
              <p className="text-caption text-muted-foreground">Posting as yourself</p>
            </div>
          </div>

          {/* Type toggle */}
          <div>
            <Label className="mb-2 block text-body-sm font-medium text-foreground">I am…</Label>
            <div className="flex gap-2">
              {(["request", "offer"] as const).map((t) => (
                <button
                  key={t}
                  onClick={() => setPostType(t)}
                  className={`flex-1 rounded-xl border-2 py-2.5 text-body-sm font-semibold transition-all ${
                    postType === t
                      ? t === "request"
                        ? "border-rose-400 bg-rose-50 text-rose-700"
                        : "border-emerald-400 bg-emerald-50 text-emerald-700"
                      : "border-border bg-background text-muted-foreground hover:border-muted-foreground"
                  }`}
                >
                  {t === "request" ? "Asking for Help" : "Offering Help"}
                </button>
              ))}
            </div>
          </div>

          {/* Category picker */}
          <div>
            <Label className="mb-2 block text-body-sm font-medium text-foreground">Category</Label>
            <div className="flex flex-wrap gap-2">
              {CATEGORIES.map(({ label, icon: Icon }) => (
                <button
                  key={label}
                  onClick={() => setPostCategory(label)}
                  className={`flex items-center gap-1.5 rounded-full border px-3 py-1.5 text-body-sm transition-all ${
                    postCategory === label
                      ? "border-primary bg-primary text-primary-foreground"
                      : "border-border bg-background text-muted-foreground hover:border-primary/50"
                  }`}
                >
                  <Icon className="h-3.5 w-3.5" />
                  {label}
                </button>
              ))}
            </div>
          </div>

          {/* Message */}
          <div>
            <Label className="mb-2 block text-body-sm font-medium text-foreground">Your message</Label>
            <Textarea
              rows={3}
              placeholder={
                postType === "request"
                  ? "Describe what you need help with…"
                  : "Describe what you'd like to offer…"
              }
              value={postMessage}
              onChange={(e) => setPostMessage(e.target.value)}
              className="resize-none text-body"
            />
          </div>

          {/* Actions */}
          <div className="flex gap-3 pt-1">
            <Button variant="outline" className="flex-1" onClick={() => setPostOpen(false)}>
              Cancel
            </Button>
            <Button className="flex-1" disabled={!postMessage.trim()} onClick={handleSubmitPost}>
              <Plus className="mr-1.5 h-4 w-4" />
              Post
            </Button>
          </div>
        </DialogContent>
      </Dialog>}
    </div>
  );
}
