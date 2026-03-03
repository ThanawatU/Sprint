<template>
  <div>
    <div class="px-4 py-8 mx-auto max-w-7xl sm:px-6 lg:px-8">
      <!-- SEARCH SECTION -->
      <div
        class="p-6 mb-8 bg-white border border-gray-300 rounded-lg shadow-md"
      >
        <h2 class="mb-6 text-xl font-semibold text-gray-900">
          ประวัติการรายงานของฉัน
        </h2>

        <form
          @submit.prevent="handleSearch"
          class="grid grid-cols-1 gap-4 md:grid-cols-5"
        >
          <!-- คำค้น -->
          <div>
            <label class="block mb-2 text-sm font-medium text-gray-700">
              คำค้นหา
            </label>
            <input
              v-model="searchForm.keyword"
              type="text"
              placeholder="ค้นหาคำอธิบาย..."
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <!-- ประเภท -->
          <div>
            <label class="block mb-2 text-sm font-medium text-gray-700">
              ประเภท
            </label>
            <select
              v-model="searchForm.category"
              class="w-full px-3 py-2 border border-gray-300 rounded-md"
            >
              <option value="">ทุกประเภท</option>
              <option value="DANGEROUS_DRIVING">ขับรถอันตราย</option>
              <option value="AGGRESSIVE_BEHAVIOR">พฤติกรรมก้าวร้าว</option>
              <option value="HARASSMENT">คุกคาม</option>
              <option value="NO_SHOW">ไม่มาตามนัด</option>
              <option value="FRAUD_OR_SCAM">ฉ้อโกง</option>
              <option value="OTHER">อื่น ๆ</option>
            </select>
          </div>

          <!-- สถานะ -->
          <div>
            <label class="block mb-2 text-sm font-medium text-gray-700">
              สถานะ
            </label>
            <select
              v-model="searchForm.status"
              class="w-full px-3 py-2 border border-gray-300 rounded-md"
            >
              <option value="">ทุกสถานะ</option>
              <option value="FILED">รอการตรวจสอบ</option>
              <option value="UNDER_REVIEW">กำลังพิจารณา</option>
              <option value="INVESTIGATING">กำลังตรวจสอบข้อเท็จจริง</option>
              <option value="RESOLVED">แก้ไขเรียบร้อยแล้ว</option>
              <option value="REJECTED">ปฏิเสธคำร้อง</option>
              <option value="CLOSED">ปิดเคสแล้ว</option>
            </select>
          </div>

          <!-- วันที่ -->
          <div>
            <label class="block mb-2 text-sm font-medium text-gray-700">
              วันที่แจ้ง
            </label>
            <input
              v-model="searchForm.date"
              type="date"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <!-- ปุ่ม -->
          <div class="flex items-end">
            <div class="flex w-full gap-2">
              <button
                type="submit"
                class="flex-1 px-5 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700"
              >
                ค้นหา
              </button>

              <button
                type="button"
                @click="handleReset"
                class="flex-1 px-5 py-2 text-gray-800 bg-gray-200 rounded-md hover:bg-gray-300"
              >
                รีเซ็ต
              </button>
            </div>
          </div>
        </form>
      </div>

      <!-- RESULT SECTION -->
      <div class="bg-white border border-gray-300 rounded-lg shadow-md">
        <div class="p-6 border-b border-gray-300">
          <h3 class="text-lg font-semibold text-gray-900">
            รายการรายงาน ({{ reportCases.length }} รายการ)
          </h3>
        </div>

        <div v-if="isLoading" class="p-6 text-center text-gray-500">
          กำลังโหลดข้อมูล...
        </div>

        <div v-else class="divide-y divide-gray-200">
          <div
            v-if="reportCases.length === 0"
            class="p-6 text-center text-gray-500"
          >
            ยังไม่มีประวัติการรายงาน
          </div>

          <!-- CARD -->
          <div
            v-for="report in reportCases"
            :key="report.id"
            class="p-6 transition-all duration-300 cursor-pointer hover:shadow-lg"
            @click.self="toggleDetails(report)"
          >
            <div class="flex items-start justify-between">
              <div>
                <h4 class="font-semibold text-gray-900">
                  {{ formatCategory(report.category) }}
                </h4>

                <div class="mt-1 text-sm text-gray-600">
                  วันที่แจ้ง: {{ formatDate(report.createdAt) }}
                </div>
              </div>

              <span :class="statusClass(report.status)">
                {{ formatStatus(report.status) }}
              </span>
            </div>

            <!-- DETAIL -->
            <div
              v-if="selectedReport?.id === report.id"
              class="pt-4 mt-4 border-t border-gray-300"
            >
              <h5 class="mb-2 font-medium text-gray-900">
                รายละเอียดการรายงาน
              </h5>
              <div class="mt-4">
                <div class="mt-4">
                  <p
                    class="p-3 text-sm text-gray-700 bg-gray-50 rounded-md whitespace-pre-line"
                  >
                    {{ report.description || "-" }}
                  </p>
                </div>
              </div>

              <!-- EVIDENCE LIST -->
              <!-- หลักฐานเดิม -->
              <div
                v-if="
                  Array.isArray(selectedReport?.evidences) &&
                  selectedReport.evidences.length
                "
              >
                <label class="block mb-2 text-sm font-medium text-gray-700">
                  หลักฐานที่เคยแนบไว้
                </label>

                <div class="grid grid-cols-2 gap-3 md:grid-cols-3">
                  <div v-for="ev in selectedReport.evidences" :key="ev.id">
                    <img
                      v-if="ev.type === 'IMAGE'"
                      :src="ev.url"
                      class="object-cover w-full border border-gray-300 rounded-lg aspect-video"
                    />

                    <video
                      v-else-if="ev.type === 'VIDEO'"
                      controls
                      class="w-full border border-gray-300 rounded-lg aspect-video"
                    >
                      <source :src="ev.url" />
                    </video>

                    <a
                      v-else
                      :href="ev.url"
                      target="_blank"
                      class="text-sm text-blue-600 underline"
                    >
                      ดาวน์โหลดไฟล์
                    </a>
                  </div>
                </div>
              </div>

              <!-- แนบหลักฐานเพิ่ม -->
              <div class="mt-4">
                <label class="block mb-1 text-sm text-gray-700">
                  แนบหลักฐานเพิ่มเติม
                </label>

                <input
                  type="file"
                  multiple
                  @change="handleFileChange"
                  class="w-full text-sm"
                />
                <button
                  v-if="canAddEvidence(report.status)"
                  @click="uploadEvidence(report.id)"
                  class="px-4 py-2 mt-2 text-sm text-white bg-blue-600 rounded-md hover:bg-blue-700"
                >
                  อัปโหลดหลักฐาน
                </button>

                <!-- preview ไฟล์ใหม่ -->
                <div
                  v-if="selectedFiles.length"
                  class="grid grid-cols-2 gap-3 mt-3 md:grid-cols-3"
                >
                  <div v-for="(file, index) in selectedFiles" :key="index">
                    <div class="p-2 text-xs text-gray-700 bg-gray-100 rounded">
                      {{ file.name }}
                    </div>
                  </div>
                </div>
              </div>

              <!-- ADMIN NOTES -->
              <div v-if="report.adminNotes" class="mt-4">
                <h5 class="mb-2 font-medium text-gray-900">
                  หมายเหตุจากผู้ดูแล
                </h5>
                <p class="p-3 text-sm text-gray-700 bg-blue-50 rounded-md">
                  {{ report.adminNotes }}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- ERROR -->
      <div
        v-if="errorMessage"
        class="p-4 mt-4 text-red-600 bg-red-50 rounded-md"
      >
        {{ errorMessage }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useRouter, useCookie } from "#app";

const router = useRouter();
const allReportCases = ref([]);
const selectedReport = ref(null);
const isLoading = ref(false);
const errorMessage = ref("");
const uploadingReportId = ref(null);
const selectedFiles = ref([]);
const reportCases = computed(() => {
  let filtered = [...allReportCases.value];

  if (searchForm.value.keyword?.trim()) {
    const keyword = searchForm.value.keyword.toLowerCase();
    filtered = filtered.filter((r) =>
      r.description?.toLowerCase().includes(keyword),
    );
  }

  if (searchForm.value.category) {
    filtered = filtered.filter((r) => r.category === searchForm.value.category);
  }

  if (searchForm.value.status) {
    filtered = filtered.filter((r) => r.status === searchForm.value.status);
  }

  if (searchForm.value.date) {
    filtered = filtered.filter((r) => {
      const reportDate = new Date(r.createdAt).toISOString().split("T")[0];

      return reportDate === searchForm.value.date;
    });
  }

  return filtered;
});

const searchForm = ref({
  keyword: "",
  category: "",
  status: "",
  date: "",
});

const canAddEvidence = (status) => {
  return !["RESOLVED", "REJECTED", "CLOSED"].includes(status);
};

const handleFileChange = (event) => {
  selectedFiles.value = Array.from(event.target.files);
};

const uploadToCloudinary = async (file) => {
  const formData = new FormData();
  formData.append("file", file);
  formData.append("upload_preset", "reports_unsigned");

  const response = await fetch(
    "https://api.cloudinary.com/v1_1/dvxmlgoz5/auto/upload",
    {
      method: "POST",
      body: formData,
    },
  );

  if (!response.ok) {
    throw new Error("อัปโหลด Cloudinary ไม่สำเร็จ");
  }

  return response.json();
};

const uploadEvidence = async (reportId) => {
  try {
    const token = useCookie("token").value;
    if (!token || !selectedFiles.value.length) return;

    const targetReport = allReportCases.value.find((r) => r.id === reportId);
    if (!targetReport) return;

    if (!canAddEvidence(targetReport.status)) {
      alert("ไม่สามารถเพิ่มหลักฐานในสถานะนี้ได้");
      return;
    }

    uploadingReportId.value = reportId;

    const newEvidences = [];

    for (const file of selectedFiles.value) {
      const cloudinaryData = await uploadToCloudinary(file);

      newEvidences.push({
        type: file.type.startsWith("video") ? "VIDEO" : "IMAGE",
        url: cloudinaryData.secure_url,
        fileName: file.name,
        mimeType: file.type,
        fileSize: file.size,
      });
    }

    const response = await fetch(
      `http://localhost:3000/api/reports/${reportId}/evidence`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ evidences: newEvidences }),
      },
    );

    if (!response.ok) {
      throw new Error("บันทึกหลักฐานไม่สำเร็จ");
    }

    targetReport.evidences = [
      ...(targetReport.evidences || []),
      ...newEvidences,
    ];

    selectedFiles.value = [];
  } catch (err) {
    errorMessage.value = err.message;
  } finally {
    uploadingReportId.value = null;
  }
};

const fetchReports = async () => {
  try {
    const token = useCookie("token").value;
    if (!token) {
      router.push("/login");
      return;
    }

    isLoading.value = true;
    errorMessage.value = "";
    selectedReport.value = null;

    const query = new URLSearchParams();

    if (searchForm.value.keyword?.trim()) {
      query.append("keyword", searchForm.value.keyword.trim());
    }

    if (searchForm.value.category) {
      query.append("category", searchForm.value.category);
    }

    if (searchForm.value.status) {
      query.append("status", searchForm.value.status);
    }

    const response = await fetch(
      `http://localhost:3000/api/reports/my?${query.toString()}`,
      {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      },
    );

    if (response.status === 401) {
      router.push("/login");
      return;
    }

    if (!response.ok) {
      throw new Error("โหลดข้อมูลไม่สำเร็จ");
    }

    const data = await response.json();
    allReportCases.value = data.data || data;
  } catch (err) {
    errorMessage.value = err.message;
  } finally {
    isLoading.value = false;
  }
};

const formatCategory = (category) => {
  const map = {
    DANGEROUS_DRIVING: "ขับรถอันตราย",
    AGGRESSIVE_BEHAVIOR: "พฤติกรรมก้าวร้าว",
    HARASSMENT: "คุกคาม",
    NO_SHOW: "ไม่มาตามนัด",
    FRAUD_OR_SCAM: "ฉ้อโกง",
    OTHER: "อื่น ๆ",
  };
  return map[category] || category;
};

const formatDate = (date) => {
  if (!date) return "-";
  return new Date(date).toLocaleDateString("th-TH", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
};

const statusClass = (status) => {
  const map = {
    FILED:
      "px-3 py-1 text-xs font-medium bg-yellow-100 text-yellow-800 rounded-full",
    UNDER_REVIEW:
      "px-3 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-full",
    INVESTIGATING:
      "px-3 py-1 text-xs font-medium bg-indigo-100 text-indigo-800 rounded-full",
    RESOLVED:
      "px-3 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-full",
    REJECTED:
      "px-3 py-1 text-xs font-medium bg-red-100 text-red-800 rounded-full",
    CLOSED:
      "px-3 py-1 text-xs font-medium bg-gray-200 text-gray-800 rounded-full",
  };
  return map[status] || "";
};

const formatStatus = (status) => {
  const map = {
    FILED: "รอการตรวจสอบ",
    UNDER_REVIEW: "กำลังพิจารณา",
    INVESTIGATING: "กำลังตรวจสอบข้อเท็จจริง",
    RESOLVED: "แก้ไขเรียบร้อยแล้ว",
    REJECTED: "ปฏิเสธคำร้อง",
    CLOSED: "ปิดเคสแล้ว",
  };
  return map[status] || status;
};

const handleSearch = async () => {
  selectedReport.value = null;
  await fetchReports();
};

const handleReset = () => {
  searchForm.value = {
    keyword: "",
    category: "",
    status: "",
    date: "",
  };

  selectedReport.value = null;
};

const toggleDetails = (report) => {
  selectedReport.value = selectedReport.value?.id === report.id ? null : report;
};

onMounted(() => {
  fetchReports();
});
</script>
