import { useState } from "react";
import { Sparkles, Car, CheckCircle, Bell } from "lucide-react";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";

export function NOHACheckIn() {
  const [rideBooked, setRideBooked] = useState(false);
  const [nohaActed, setNohaActed] = useState(false);

  const handleRide = () => {
    setRideBooked(true);
    toast.success("Lyft booked for 8:40 AM Saturday — plenty of time to arrive.");
  };

  const handleSignUp = () => {
    setNohaActed(true);
    toast.success("You're signed up for Chair Yoga on Saturday at 9:00 AM!");
  };

  return (
    <div className="relative overflow-hidden rounded-2xl border border-primary/20 bg-gradient-to-br from-primary/5 to-primary/10 p-5 shadow-card">
      {/* Decorative blob */}
      <div className="pointer-events-none absolute -right-8 -top-8 h-32 w-32 rounded-full bg-primary/10 blur-2xl" />

      <div className="flex items-start gap-4">
        {/* NOHA Avatar */}
        <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-primary shadow-sm">
          <Sparkles className="h-5 w-5 text-primary-foreground" />
        </div>

        <div className="min-w-0 flex-1">
          <div className="mb-1.5 flex items-center gap-2">
            <span className="text-body font-semibold text-foreground">NOHA</span>
            <span className="rounded-full bg-primary/15 px-2 py-0.5 text-caption font-medium text-primary">
              Daily Check-In
            </span>
          </div>

          {nohaActed ? (
            <div className="space-y-1">
              <p className="text-body-sm text-foreground">
                <span className="font-medium">Done!</span> You're signed up for Chair Yoga on Saturday
                at 9:00 AM. I'll send you a reminder Friday evening.
              </p>
              <p className="text-body-sm text-muted-foreground">
                Barbara and Marcus will be there too — you'll know some familiar faces.
              </p>
              {!rideBooked ? (
                <div className="pt-2">
                  <Button size="sm" variant="outline" onClick={handleRide} className="text-body-sm">
                    <Car className="mr-1.5 h-3.5 w-3.5" />
                    Also arrange a Lyft
                  </Button>
                </div>
              ) : (
                <div className="flex w-fit items-center gap-1.5 rounded-md border border-teal-200 bg-teal-50 px-3 py-1.5 text-body-sm text-teal-700 mt-2">
                  <Car className="h-3.5 w-3.5" />
                  Lyft arranged for 8:40 AM Saturday
                </div>
              )}
            </div>
          ) : (
            <div className="space-y-2">
              <p className="text-body-sm text-foreground">
                Good morning, Frank. You got about 5 hours of sleep last night and your steps have
                been low this week — 390 yesterday. I know the days can feel long.
              </p>
              <p className="text-body-sm text-foreground">
                There's a <strong>Chair Yoga session Saturday at 9am</strong> — Barbara and Marcus are
                going, small group, very gentle. Want me to sign you up?
              </p>
              <div className="flex flex-wrap gap-2 pt-1">
                <Button size="sm" onClick={handleSignUp} className="text-body-sm">
                  <CheckCircle className="mr-1.5 h-3.5 w-3.5" />
                  Sign Me Up
                </Button>
                {!rideBooked ? (
                  <Button size="sm" variant="outline" onClick={handleRide} className="text-body-sm">
                    <Car className="mr-1.5 h-3.5 w-3.5" />
                    Arrange a Lyft
                  </Button>
                ) : (
                  <div className="flex items-center gap-1.5 rounded-md border border-teal-200 bg-teal-50 px-3 py-1.5 text-body-sm text-teal-700">
                    <CheckCircle className="h-3.5 w-3.5" />
                    Lyft at 8:40 AM
                  </div>
                )}
                <Button size="sm" variant="ghost" className="text-body-sm text-muted-foreground">
                  <Bell className="mr-1.5 h-3.5 w-3.5" />
                  Remind Me Later
                </Button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
