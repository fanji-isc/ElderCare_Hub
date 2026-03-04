import { Heart, Bell, Settings, Users, Stethoscope, HandHeart, Check } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useNavigate, useLocation } from "react-router-dom";

const VIEWS = [
  {
    to: "/family",
    label: "Family Member",
    description: "Health monitoring dashboard",
    icon: Users,
    initials: "FM",
    color: "bg-violet-100 text-violet-600",
  },
  {
    to: "/physician",
    label: "Physician",
    description: "Clinical patient data",
    icon: Stethoscope,
    initials: "DR",
    color: "bg-blue-100 text-blue-600",
  },
  {
    to: "/elder",
    label: "Frank",
    description: "Voice assistant & community",
    icon: HandHeart,
    initials: "F",
    color: "bg-rose-100 text-rose-600",
  },
] as const;

export function Header() {
  const navigate = useNavigate();
  const { pathname } = useLocation();

  const activeView = VIEWS.find((v) => pathname.startsWith(v.to)) ?? VIEWS[0];

  return (
    <header className="sticky top-0 z-50 w-full border-b border-border bg-background/80 backdrop-blur-lg">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary">
            <Heart className="h-5 w-5 text-primary-foreground" />
          </div>
          <div>
            <h1 className="text-body font-display font-semibold text-foreground">Neighborhood Health Hub</h1>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <Button variant="ghost" size="icon" className="relative">
            <Bell className="h-5 w-5" />
            <span className="absolute right-1 top-1 h-2 w-2 rounded-full bg-destructive" />
          </Button>
          <Button variant="ghost" size="icon">
            <Settings className="h-5 w-5" />
          </Button>

          {/* User / view switcher */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button className="ml-2 flex h-9 w-9 items-center justify-center rounded-full bg-primary/10 transition-colors hover:bg-primary/20 focus:outline-none focus-visible:ring-2 focus-visible:ring-primary">
                <span className={`text-caption font-bold ${activeView.color.split(" ")[1]}`}>
                  {activeView.initials}
                </span>
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56">
              <DropdownMenuLabel className="text-caption text-muted-foreground font-normal">
                Switch view
              </DropdownMenuLabel>
              <DropdownMenuSeparator />
              {VIEWS.map((view) => {
                const Icon = view.icon;
                const isActive = pathname.startsWith(view.to);
                return (
                  <DropdownMenuItem
                    key={view.to}
                    onClick={() => navigate(view.to)}
                    className="flex cursor-pointer items-center gap-3 px-3 py-2.5"
                  >
                    <div className={`flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg ${view.color}`}>
                      <Icon className="h-4 w-4" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-body-sm font-medium text-foreground">{view.label}</p>
                    </div>
                    {isActive && <Check className="h-4 w-4 flex-shrink-0 text-primary" />}
                  </DropdownMenuItem>
                );
              })}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
}
