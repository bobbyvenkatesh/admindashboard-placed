import { createClient } from "@/utils/supabase/server";
import { cookies } from "next/headers";

export default async function Page() {
  const cookieStore = await cookies();
  const supabase = createClient(cookieStore);

  const { data: students, error } = await supabase
    .from("admin_students")
    .select("*");

  if (error) {
    console.error("Failed to fetch students:", error.message);
  }

  return (
    <main style={{ padding: 32, fontFamily: "system-ui, sans-serif", maxWidth: 800, margin: "0 auto" }}>
      <h1>Placement &amp; Assessment Intelligence</h1>
      <p style={{ color: "#6B7280" }}>Supabase Live Connected Candidates</p>
      <ul style={{ lineHeight: 1.8 }}>
        {students && students.length > 0 ? (
          students.map((student: any) => (
            <li key={student.id}>
              <strong>{student.name}</strong> — {student.department} ({student.institution}) | Readiness: {student.readiness}% ({student.risk} Risk)
            </li>
          ))
        ) : (
          <li>No candidate records found. Use the dashboard to onboard or upload candidates.</li>
        )}
      </ul>
    </main>
  );
}
