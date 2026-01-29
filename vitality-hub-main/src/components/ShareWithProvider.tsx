import { useState } from "react";
import { Share2, Mail, Download, CheckCircle2, Building2, User } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { toast } from "sonner";

export function ShareWithProvider() {
  const [email, setEmail] = useState("");
  const [isShared, setIsShared] = useState(false);
  const [isOpen, setIsOpen] = useState(false);

  const handleShare = () => {
    if (!email) {
      toast.error("Please enter your provider's email");
      return;
    }
    // Simulate sharing
    setIsShared(true);
    toast.success("Health data shared successfully!");
    setTimeout(() => {
      setIsShared(false);
      setEmail("");
      setIsOpen(false);
    }, 2000);
  };

  const handleExport = () => {
    toast.success("Health report exported as PDF");
  };

  return (
    <div className="rounded-2xl bg-card p-6 shadow-card">
      <div className="mb-6">
        <h3 className="text-heading font-display text-foreground">Share with Healthcare Provider</h3>
        <p className="text-body-sm text-muted-foreground">
          Securely share your health data with your doctor or caregiver
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <Dialog open={isOpen} onOpenChange={setIsOpen}>
          <DialogTrigger asChild>
            <Button
              className="h-auto flex-col gap-3 p-6 bg-primary hover:bg-primary/90 text-primary-foreground"
            >
              <Share2 className="h-8 w-8" />
              <div className="text-center">
                <p className="text-body font-medium">Share via Email</p>
                <p className="text-caption opacity-80">Send to your provider</p>
              </div>
            </Button>
          </DialogTrigger>
          <DialogContent className="sm:max-w-md">
            <DialogHeader>
              <DialogTitle className="font-display">Share Health Data</DialogTitle>
              <DialogDescription>
                Enter your healthcare provider's email to securely share your health summary.
              </DialogDescription>
            </DialogHeader>

            {isShared ? (
              <div className="flex flex-col items-center gap-4 py-8">
                <div className="flex h-16 w-16 items-center justify-center rounded-full bg-success/10">
                  <CheckCircle2 className="h-8 w-8 text-success" />
                </div>
                <p className="text-body font-medium text-foreground">Data Shared Successfully!</p>
              </div>
            ) : (
              <div className="space-y-4">
                <div className="space-y-2">
                  <label className="text-body-sm font-medium text-foreground">Provider Email</label>
                  <Input
                    type="email"
                    placeholder="doctor@clinic.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="text-body"
                  />
                </div>

                <div className="rounded-xl bg-muted/50 p-4">
                  <p className="text-body-sm text-muted-foreground">
                    <strong className="text-foreground">Data included:</strong> Vital signs, heart rate trends, ECG readings, sleep analysis, stress levels, and fall risk assessment.
                  </p>
                </div>

                <Button onClick={handleShare} className="w-full bg-primary hover:bg-primary/90">
                  <Mail className="mr-2 h-4 w-4" />
                  Send Health Summary
                </Button>
              </div>
            )}
          </DialogContent>
        </Dialog>

        <Button
          variant="outline"
          className="h-auto flex-col gap-3 p-6 border-2 hover:bg-muted"
          onClick={handleExport}
        >
          <Download className="h-8 w-8 text-primary" />
          <div className="text-center">
            <p className="text-body font-medium text-foreground">Export Report</p>
            <p className="text-caption text-muted-foreground">Download as PDF</p>
          </div>
        </Button>
      </div>

      <div className="mt-6 rounded-xl bg-muted/50 p-4">
        <div className="flex items-start gap-3">
          <Building2 className="mt-0.5 h-5 w-5 text-primary" />
          <div>
            <p className="text-body-sm font-medium text-foreground">Connected Providers</p>
            <div className="mt-2 flex items-center gap-2">
              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/10">
                <User className="h-4 w-4 text-primary" />
              </div>
              <div>
                <p className="text-body-sm text-foreground">Dr. Sarah Johnson</p>
                <p className="text-caption text-muted-foreground">Last shared: 3 days ago</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
