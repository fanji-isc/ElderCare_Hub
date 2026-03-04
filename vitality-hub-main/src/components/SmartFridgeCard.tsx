import { useEffect, useState } from "react";
import { Refrigerator, AlertTriangle, ShoppingCart, Utensils, Flame } from "lucide-react";

const API_BASE = "http://localhost:3001";
const PATIENT_ID = "PATIENT_001";

type StockLevel = "low" | "medium" | "full";

type FridgeDay = {
  calendarDate: string;
  inventory: { item: string; quantity: string; expiresInDays: number; category: string; stockLevel: StockLevel }[];
  dailyNutrition: { calories: number; protein: number; carbs: number; fat: number; fiber: number; waterLiters: number };
  mealsDetected: { time: string; meal: string; items: string[]; calories: number }[];
  alerts: { type: string; item?: string; message: string }[];
};

const FALLBACK: FridgeDay = {
  calendarDate: "2026-02-26",
  inventory: [
    { item: "Milk", quantity: "0.8 L", expiresInDays: 1, category: "dairy", stockLevel: "low" },
    { item: "Greek Yogurt", quantity: "1 cup", expiresInDays: 3, category: "dairy", stockLevel: "low" },
    { item: "Oranges", quantity: "5 pieces", expiresInDays: 6, category: "fruit", stockLevel: "full" },
    { item: "Carrots", quantity: "300 g", expiresInDays: 8, category: "vegetable", stockLevel: "medium" },
    { item: "Turkey Slices", quantity: "150 g", expiresInDays: 2, category: "protein", stockLevel: "low" },
    { item: "Almond Milk", quantity: "600 ml", expiresInDays: 7, category: "beverage", stockLevel: "medium" },
    { item: "Eggs", quantity: "3 pieces", expiresInDays: 12, category: "protein", stockLevel: "low" },
    { item: "Cottage Cheese", quantity: "200 g", expiresInDays: 6, category: "dairy", stockLevel: "medium" },
    { item: "Strawberries", quantity: "200 g", expiresInDays: 3, category: "fruit", stockLevel: "low" },
  ],
  dailyNutrition: { calories: 1640, protein: 58, carbs: 188, fat: 47, fiber: 25, waterLiters: 1.9 },
  mealsDetected: [
    { time: "07:30", meal: "Breakfast", items: ["Greek Yogurt", "Strawberries"], calories: 290 },
    { time: "12:45", meal: "Lunch", items: ["Turkey Slices", "Carrots"], calories: 380 },
  ],
  alerts: [
    { type: "expiring", item: "Milk", message: "Milk expires tomorrow" },
    { type: "expiring", item: "Turkey Slices", message: "Turkey Slices expire in 2 days" },
  ],
};

function pickLatest(list: any[]): FridgeDay {
  if (!Array.isArray(list) || list.length === 0) return FALLBACK;
  return [...list].sort((a, b) =>
    String(b?.calendarDate || "").localeCompare(String(a?.calendarDate || ""))
  )[0] as FridgeDay;
}

const CALORIE_GOAL = 2000;

export function SmartFridgeCard() {
  const [data, setData] = useState<FridgeDay>(FALLBACK);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch(`${API_BASE}/api/fridge?patient_id=${encodeURIComponent(PATIENT_ID)}`);
        const json = res.ok ? await res.json() : [];
        setData(pickLatest(Array.isArray(json) ? json : []));
      } catch { /* fallback stays */ }
    })();
  }, []);

  const { dailyNutrition: n, mealsDetected: meals, inventory, alerts } = data;
  const lowStock = inventory.filter((i) => i.stockLevel === "low");
  const expiring = alerts.filter((a) => a.type === "expiring");
  const caloriePct = Math.min(100, Math.round((n.calories / CALORIE_GOAL) * 100));

  return (
    <div className="rounded-2xl bg-card shadow-card overflow-hidden">

      {/* Banner header */}
      <div className="flex items-center gap-3 border-b border-border bg-gradient-to-r from-teal-50 to-emerald-50 px-6 py-4">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-teal-500 text-primary-foreground">
          <Refrigerator className="h-5 w-5" />
        </div>
        <div className="flex-1">
          <h3 className="text-heading font-display text-foreground">Smart Fridge</h3>
          <p className="text-caption text-muted-foreground">Diet & nutrition monitoring</p>
        </div>
        <span className="text-caption text-muted-foreground">
          {new Date(data.calendarDate + "T12:00:00").toLocaleDateString("en-US", { month: "short", day: "numeric" })}
        </span>
      </div>

      <div className="space-y-4 p-6">

        {/* Calories */}
        <div>
          <div className="mb-1.5 flex items-center justify-between">
            <div className="flex items-center gap-1.5 text-body-sm font-medium text-foreground">
              <Flame className="h-4 w-4 text-orange-500" />
              Calories Today
            </div>
            <span className="text-body-sm font-bold text-orange-600">{n.calories} / {CALORIE_GOAL} kcal</span>
          </div>
          <div className="h-2 w-full rounded-full bg-muted">
            <div
              className="h-2 rounded-full bg-orange-400 transition-all"
              style={{ width: `${caloriePct}%` }}
            />
          </div>
          <p className="mt-1 text-caption text-muted-foreground">{caloriePct}% of daily goal</p>
        </div>

        {/* Meals */}
        <div>
          <div className="mb-2 flex items-center gap-1.5 text-body-sm font-medium text-muted-foreground">
            <Utensils className="h-3.5 w-3.5" />
            Meals Detected
          </div>
          <div className="space-y-1.5">
            {meals.map((m, i) => (
              <div key={i} className="flex items-center justify-between rounded-lg bg-muted/40 px-3 py-2">
                <div>
                  <span className="text-body-sm font-medium text-foreground">{m.meal}</span>
                  <span className="ml-2 text-caption text-muted-foreground">{m.time}</span>
                  <p className="text-caption text-muted-foreground">{m.items.join(" · ")}</p>
                </div>
                <span className="text-caption font-semibold text-orange-600">{m.calories} kcal</span>
              </div>
            ))}
          </div>
        </div>

        {/* Shopping reminder */}
        {lowStock.length > 0 && (
          <div className="rounded-xl border border-rose-200 bg-rose-50 p-3">
            <div className="mb-2 flex items-center gap-2">
              <ShoppingCart className="h-4 w-4 text-rose-500" />
              <p className="text-body-sm font-semibold text-rose-800">
                Shopping needed — {lowStock.length} item{lowStock.length > 1 ? "s" : ""} running low
              </p>
            </div>
            <div className="flex flex-wrap gap-1.5">
              {lowStock.map((item, i) => (
                <span key={i} className="inline-flex items-center gap-1 rounded-full bg-white px-2.5 py-0.5 text-caption font-medium text-rose-700 shadow-sm">
                  {item.item}
                  <span className="text-muted-foreground">· {item.quantity}</span>
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Expiry alerts */}
        {expiring.length > 0 && (
          <div className="space-y-1.5">
            {expiring.map((a, i) => (
              <div key={i} className="flex items-center gap-2 rounded-lg bg-amber-50 px-3 py-2">
                <AlertTriangle className="h-3.5 w-3.5 flex-shrink-0 text-amber-500" />
                <p className="text-caption text-amber-800">{a.message}</p>
              </div>
            ))}
          </div>
        )}

      </div>
    </div>
  );
}

