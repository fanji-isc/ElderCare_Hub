import React, { useEffect, useRef, useState } from "react";
import {
  MapPin,
  Clock,
  Footprints,
  Moon,
  Heart,
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

const API_BASE = import.meta.env.VITE_API_BASE ?? "";
const PATIENT_ID = "PATIENT_001";

// ─── Data Types ───────────────────────────────────────────────────────────────

interface Attendee { name: string; initials: string; color: string; }

interface Activity {
  id: number;
  title: string;
  subtitle: string;
  date: string;
  time: string;
  location: string;
  duration: string;
  category: string;
  attendees: Attendee[];
  extraCount: number;
  badge: string | null;
  badgeColor: string | null;
  highlighted: boolean;
}

interface FeedItem {
  id: number;
  name: string;
  initials: string;
  color: string;
  activity: string;
  time: string;
  icon: string;
}

interface HelpPost {
  id: number;
  type: "request" | "offer";
  name: string;
  initials: string;
  color: string;
  message: string;
  date: string;
  time: string;
  category: string;
  isFrank?: boolean;
}

// ─── Visual Mapping Tables (all Tailwind classes kept static for purge safety) ─

// Attendee / avatar colors: JSON stores short key, frontend maps to full class
const COLOR_CLASSES: Record<string, string> = {
  rose:    "bg-rose-100 text-rose-600",
  teal:    "bg-teal-100 text-teal-600",
  violet:  "bg-violet-100 text-violet-600",
  amber:   "bg-amber-100 text-amber-600",
  blue:    "bg-blue-100 text-blue-600",
  pink:    "bg-pink-100 text-pink-600",
  emerald: "bg-emerald-100 text-emerald-600",
  purple:  "bg-purple-100 text-purple-600",
  indigo:  "bg-indigo-100 text-indigo-600",
  orange:  "bg-orange-100 text-orange-600",
  green:   "bg-green-100 text-green-600",
};

// Activity badge colors
const BADGE_COLOR_CLASSES: Record<string, string> = {
  teal:    "bg-teal-100 text-teal-700",
  emerald: "bg-emerald-100 text-emerald-700",
  amber:   "bg-amber-100 text-amber-700",
  rose:    "bg-rose-100 text-rose-700",
  violet:  "bg-violet-100 text-violet-700",
  blue:    "bg-blue-100 text-blue-700",
};

// Activity category → gradient + icon
const ACTIVITY_STYLE: Record<string, { gradient: string; icon: React.ElementType }> = {
  exercise:     { gradient: "from-violet-500 to-purple-600",  icon: Activity },
  walk:         { gradient: "from-teal-500 to-cyan-600",      icon: Footprints },
  meditation:   { gradient: "from-indigo-500 to-blue-600",    icon: Sparkles },
  hiking:       { gradient: "from-emerald-500 to-green-600",  icon: Mountain },
  games:        { gradient: "from-orange-400 to-amber-500",   icon: Star },
  storytelling: { gradient: "from-rose-400 to-pink-500",      icon: MessageCircle },
  gardening:    { gradient: "from-green-500 to-emerald-600",  icon: Mountain },
  cooking:      { gradient: "from-amber-500 to-orange-600",   icon: Utensils },
  movie:        { gradient: "from-sky-500 to-blue-600",       icon: Star },
  music:        { gradient: "from-purple-500 to-indigo-600",  icon: Activity },
};

// Feed item icon key → icon component + colors
const FEED_STYLE: Record<string, { icon: React.ElementType; iconColor: string; bgColor: string }> = {
  walk:    { icon: Footprints,     iconColor: "text-teal-500",    bgColor: "bg-teal-50" },
  sleep:   { icon: Moon,           iconColor: "text-violet-500",  bgColor: "bg-violet-50" },
  event:   { icon: Star,           iconColor: "text-amber-500",   bgColor: "bg-amber-50" },
  health:  { icon: Heart,          iconColor: "text-rose-500",    bgColor: "bg-rose-50" },
  social:  { icon: MessageCircle,  iconColor: "text-indigo-500",  bgColor: "bg-indigo-50" },
  helping: { icon: HeartHandshake, iconColor: "text-emerald-500", bgColor: "bg-emerald-50" },
};

// Resolve a color key to a full Tailwind class (falls back if already a full class)
const resolveColor = (key: string) => COLOR_CLASSES[key] ?? key;
const resolveBadgeColor = (key: string | null) =>
  key ? (BADGE_COLOR_CLASSES[key] ?? key) : "";

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
  const [activities, setActivities] = useState<Activity[]>([]);
  const [posts, setPosts] = useState<HelpPost[]>([]);
  const [loading, setLoading] = useState(true);
  const activitiesRef = useRef<Activity[]>([]);  // stable ref for event handler closure

  const [joined,    setJoined]    = useState<Set<number>>(new Set());
  const [helped,    setHelped]    = useState<Set<number>>(new Set());
  const [connected, setConnected] = useState<Set<number>>(new Set());

  // Post dialog state
  const [postOpen,     setPostOpen]     = useState(false);
  const [postType,     setPostType]     = useState<"request" | "offer">("request");
  const [postCategory, setPostCategory] = useState("Ride");
  const [postMessage,  setPostMessage]  = useState("");

  useEffect(() => {
    fetch(`${API_BASE}/api/neighborhood?patient_id=${encodeURIComponent(PATIENT_ID)}`)
      .then((r) => r.ok ? r.json() : [])
      .then((data: any) => {
        const latest = Array.isArray(data) && data.length > 0 ? data[0] : null;
        if (latest) {
          const acts = Array.isArray(latest.activities) ? latest.activities : [];
          activitiesRef.current = acts;
          setActivities(acts);
          setPosts(Array.isArray(latest.helpPosts) ? latest.helpPosts : []);
        }
      })
      .catch(() => { /* silent — UI stays empty */ })
      .finally(() => setLoading(false));
  }, []);

  // Listen for NOHA booking a class via voice command — fires when NOHA responds with [[JOIN:id]]
  useEffect(() => {
    const handler = (e: Event) => {
      const id = (e as CustomEvent<{ id: number }>).detail.id;
      setJoined((prev) => {
        if (prev.has(id)) return prev;  // already joined — no-op
        const next = new Set(prev);
        next.add(id);
        const act = activitiesRef.current.find((a) => a.id === id);
        toast.success(`NOHA signed you up for ${act?.title ?? "the activity"}!`);
        return next;
      });
    };
    window.addEventListener("noha-join-activity", handler);
    return () => window.removeEventListener("noha-join-activity", handler);
  }, []);

  const handleHelp = (id: number, name: string) => {
    setHelped((prev) => {
      const next = new Set(prev);
      if (next.has(id)) { next.delete(id); toast.info(`Removed your offer to help ${name}.`); }
      else              { next.add(id);    toast.success(`${name} will be notified that you can help!`); }
      return next;
    });
  };

  const handleJoin = (id: number, title: string) => {
    setJoined((prev) => {
      const next = new Set(prev);
      if (next.has(id)) { next.delete(id); toast.info(`Removed from ${title}`); }
      else              { next.add(id);    toast.success(`You're signed up for ${title}!`); }
      return next;
    });
  };

  const handleDeletePost = (id: number) => {
    setPosts((prev) => prev.filter((p) => p.id !== id));
    toast.info("Your post has been removed.");
  };

  const handleSubmitPost = () => {
    if (!postMessage.trim()) return;
    const now = new Date();
    const dateStr = now.toLocaleDateString("en-US", { weekday: "short", month: "short", day: "numeric" });
    const timeStr = now.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" });
    const newPost: HelpPost = {
      id: Date.now(),
      type: postType,
      name: FRANK.name,
      initials: FRANK.initials,
      color: FRANK.color,
      message: postMessage.trim(),
      date: dateStr,
      time: timeStr,
      category: postCategory,
      isFrank: true,
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
      {(section === "all" || section === "activity") && (
        <div>
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

          {loading ? (
            <div className="py-10 text-center text-muted-foreground text-body-sm">Loading activities…</div>
          ) : (
            <div className="grid max-h-[520px] gap-4 overflow-y-auto pr-1 sm:grid-cols-2">
              {activities.map((act) => {
                const style = ACTIVITY_STYLE[act.category] ?? ACTIVITY_STYLE.exercise;
                const Icon = style.icon;
                const isJoined = joined.has(act.id);
                return (
                  <div
                    key={act.id}
                    className={`overflow-hidden rounded-2xl shadow-card transition-all duration-300 hover:-translate-y-1 hover:shadow-glow ${
                      act.highlighted ? "ring-2 ring-primary/30" : ""
                    }`}
                  >
                    {/* Gradient Header */}
                    <div className={`flex items-center gap-3 bg-gradient-to-r ${style.gradient} px-5 py-4`}>
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
                      <div className="mb-4 space-y-1.5">
                        <div className="flex items-center gap-2 text-body-sm text-foreground">
                          <Calendar className="h-3.5 w-3.5 flex-shrink-0 text-muted-foreground" />
                          <span>{act.date} · {act.time}</span>
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
                              className={`flex h-7 w-7 items-center justify-center rounded-full border-2 border-card text-caption font-semibold ${resolveColor(a.color)}`}
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
                          <span className={`rounded-full px-2.5 py-1 text-caption font-medium ${resolveBadgeColor(act.badgeColor)}`}>
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
                            <><CheckCircle className="mr-1.5 h-3.5 w-3.5" />Joined</>
                          ) : (
                            <>Join<ArrowRight className="ml-1.5 h-3.5 w-3.5" /></>
                          )}
                        </Button>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      )}

      {/* ── Helping Hand Board ───────────────────────────────────────────────── */}
      {(section === "all" || section === "helping") && (
        <div className="rounded-2xl bg-card p-6 shadow-card">
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
            <Button size="sm" variant="outline" onClick={() => setPostOpen(true)} className="text-body-sm">
              <Plus className="mr-1.5 h-3.5 w-3.5" />
              Post
            </Button>
          </div>

          <div className="flex max-h-[520px] flex-col gap-4 overflow-y-auto pr-1">
            {posts.map((post) => {
              const cat = CATEGORIES.find((c) => c.label === post.category) ?? CATEGORIES[CATEGORIES.length - 1];
              const CatIcon = cat.icon;
              const isRequest   = post.type === "request";
              const isHelping   = helped.has(post.id);
              const isConnected = connected.has(post.id);
              const isMine      = post.name === FRANK.name;
              return (
                <div
                  key={post.id}
                  className={`rounded-2xl border-2 p-5 ${
                    isRequest ? "border-rose-100 bg-rose-50/30" : "border-emerald-100 bg-emerald-50/30"
                  }`}
                >
                  <div className="mb-4 flex items-center gap-3">
                    <div className={`flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-full text-body font-bold ${resolveColor(post.color)}`}>
                      {post.initials}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <p className="text-body font-semibold text-foreground">{post.name}</p>
                        <span className={`rounded-full px-2.5 py-0.5 text-caption font-medium ${isRequest ? "bg-rose-100 text-rose-700" : "bg-emerald-100 text-emerald-700"}`}>
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

                  <div className="flex items-center gap-4">
                    <p className="flex-1 text-body leading-relaxed text-foreground">{post.message}</p>
                    {!isMine && (
                      <Button
                        variant={(!isRequest && isConnected) || (isRequest && isHelping) ? "outline" : "default"}
                        onClick={() => {
                          if (isRequest) {
                            handleHelp(post.id, post.name);
                          } else {
                            setConnected((prev) => {
                              const next = new Set(prev);
                              if (next.has(post.id)) { next.delete(post.id); toast.info(`Disconnected from ${post.name}.`); }
                              else                   { next.add(post.id);    toast.success(`Connected with ${post.name}!`); }
                              return next;
                            });
                          }
                        }}
                        className="flex-shrink-0 h-14 px-8 text-body font-semibold"
                      >
                        {isRequest ? (
                          isHelping ? <><CheckCircle className="mr-2 h-6 w-6" /> Helping!</> : <><HeartHandshake className="mr-2 h-6 w-6" /> I Can Help</>
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
      )}

      {/* ── Post Dialog ───────────────────────────────────────────────────────── */}
      {(section === "all" || section === "helping") && (
        <Dialog open={postOpen} onOpenChange={setPostOpen}>
          <DialogContent className="max-w-md">
            <DialogHeader>
              <DialogTitle className="font-display text-heading">Add to the Board</DialogTitle>
            </DialogHeader>

            <div className="flex items-center gap-3 rounded-xl bg-muted/50 px-4 py-3">
              <div className={`flex h-10 w-10 items-center justify-center rounded-full text-body font-bold ${FRANK.color}`}>
                {FRANK.initials}
              </div>
              <div>
                <p className="text-body font-semibold text-foreground">{FRANK.name}</p>
                <p className="text-caption text-muted-foreground">Posting as yourself</p>
              </div>
            </div>

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

            <div>
              <Label className="mb-2 block text-body-sm font-medium text-foreground">Your message</Label>
              <Textarea
                rows={3}
                placeholder={postType === "request" ? "Describe what you need help with…" : "Describe what you'd like to offer…"}
                value={postMessage}
                onChange={(e) => setPostMessage(e.target.value)}
                className="resize-none text-body"
              />
            </div>

            <div className="flex gap-3 pt-1">
              <Button variant="outline" className="flex-1" onClick={() => setPostOpen(false)}>Cancel</Button>
              <Button className="flex-1" disabled={!postMessage.trim()} onClick={handleSubmitPost}>
                <Plus className="mr-1.5 h-4 w-4" />
                Post
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
