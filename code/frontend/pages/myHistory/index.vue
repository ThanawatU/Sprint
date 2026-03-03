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
            class="p-6 transition-all duration-300"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <h4 class="font-semibold text-gray-900">
                  {{ formatCategory(report.category) }}
                </h4>

                <div class="mt-1 text-sm text-gray-600">
                  วันที่แจ้ง: {{ formatDate(report.createdAt) }}
                </div>
              </div>

              <div class="flex items-center gap-3">
                <span :class="statusClass(report.status)">
                  {{ formatStatus(report.status) }}
                </span>

                <button
                  @click="toggleDetails(report)"
                  class="px-4 py-2 text-sm font-medium text-white transition-colors bg-blue-600 rounded-md hover:bg-blue-700"
                >
                  {{ selectedReport?.id === report.id ? 'ปิดรายละเอียด' : 'ดูรายละเอียด' }}
                </button>
              </div>
            </div>

            <!-- DETAIL -->
            <div
              v-if="selectedReport?.id === report.id"
              class="pt-4 mt-4 border-t border-gray-300"
            >
              <h5 class="mb-2 font-medium text-gray-900">
                รายละเอียดการรายงาน
              </h5>
              
              <div class="p-4 mb-4 rounded-lg bg-gray-50">
                <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
                  <div>
                    <span class="text-sm font-medium text-gray-700">ผู้ถูกรายงาน:</span>
                    <p class="text-sm text-gray-900">
                      {{ report.driver?.firstName }} {{ report.driver?.lastName }}
                    </p>
                  </div>
                  <div>
                    <span class="text-sm font-medium text-gray-700">เลขที่การจอง:</span>
                    <p class="text-sm text-gray-900">
                      {{ report.bookingId || '-' }}
                    </p>
                  </div>
                </div>
              </div>

              <div class="mt-4">
                <h6 class="mb-2 text-sm font-medium text-gray-700">คำอธิบาย:</h6>
                <p
                  class="p-3 text-sm text-gray-700 bg-gray-50 rounded-md whitespace-pre-line"
                >
                  {{ report.description || "-" }}
                </p>
              </div>

              <!-- EVIDENCE LIST -->
              <!-- หลักฐานเดิม -->
              <div class="mt-4">
                <h6 class="mb-2 text-sm font-medium text-gray-700">
                  หลักฐานที่แนบไว้
                </h6>
                
                <div
                  v-if="
                    Array.isArray(selectedReport?.evidences) &&
                    selectedReport.evidences.length > 0
                  "
                  class="grid grid-cols-2 gap-3 md:grid-cols-3"
                >
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
                
                <div v-else class="p-3 text-sm text-gray-500 bg-gray-50 rounded-md">
                  ยังไม่มีหลักฐาน
                </div>
              </div>

              <!-- แนบหลักฐานเพิ่ม -->
              <div v-if="canAddEvidence(report.status)" class="p-4 mt-4 border border-blue-300 rounded-lg bg-blue-50">
                <h6 class="mb-2 text-sm font-semibold text-blue-900">
                  📎 ส่งหลักฐานเพิ่มเติม
                </h6>
                <p class="mb-3 text-xs text-blue-700">
                  หากคุณมีหลักฐานเพิ่มเติม (รูปภาพหรือวิดีโอ) สามารถอัปโหลดได้ที่นี่
                  <br>
                  <span class="text-blue-600">• รูปภาพและวิดีโอ - แต่ละชนิดไม่เกิน 3 ไฟล์</span>
                  <br>
                  <span class="text-blue-600">• ขนาดไม่เกิน 10MB ต่อไฟล์</span>
                </p>

                <!-- Error Message -->
                <div v-if="errorMessage" class="p-3 mb-3 text-sm text-red-700 bg-red-100 border border-red-300 rounded-md">
                  ⚠️ {{ errorMessage }}
                </div>

                <!-- Loading Indicator -->
                <div v-if="uploadingReportId === report.id" class="p-4 mb-3 text-center bg-white border border-blue-300 rounded-md">
                  <div class="inline-block w-8 h-8 border-4 border-blue-600 rounded-full border-t-transparent animate-spin"></div>
                  <p class="mt-2 text-sm text-blue-600">กำลังอัปโหลดไฟล์...</p>
                </div>

                <input
                  :id="`file-${report.id}`"
                  type="file"
                  multiple
                  accept="image/*,video/*"
                  @change="handleFileChange($event, report.id)"
                  :disabled="uploadingReportId === report.id"
                  class="w-full p-2 text-sm border border-blue-300 rounded-md disabled:bg-gray-200 disabled:cursor-not-allowed"
                />
                
                <!-- Preview ไฟล์ใหม่ -->
                <div
                  v-if="selectedFiles.length > 0"
                  class="grid grid-cols-2 gap-3 mt-3 md:grid-cols-3"
                >
                  <div v-for="(file, index) in selectedFiles" :key="index">
                    <div class="relative">
                      <img
                        v-if="file.type.startsWith('image')"
                        :src="getPreviewUrl(file)"
                        class="object-cover w-full border border-gray-300 rounded-lg aspect-video"
                      />
                      <video
                        v-else-if="file.type.startsWith('video')"
                        :src="getPreviewUrl(file)"
                        class="object-cover w-full border border-gray-300 rounded-lg aspect-video"
                        controls
                      ></video>
                      <p class="mt-1 text-xs text-gray-700 truncate">{{ file.name }}</p>
                    </div>
                  </div>
                </div>

                <button
                  @click="uploadEvidence(report.id)"
                  :disabled="uploadingReportId === report.id || selectedFiles.length === 0"
                  class="w-full px-4 py-2 mt-3 text-sm font-medium text-white transition-colors bg-blue-600 rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
                >
                  {{ uploadingReportId === report.id ? 'กำลังอัปโหลด...' : 'อัปโหลดหลักฐาน' }}
                </button>
              </div>

              <!-- สถานะปิดแล้ว -->
              <div v-else class="p-3 mt-4 text-sm text-gray-600 border border-gray-300 rounded-lg bg-gray-50">
                ℹ️ เคสนี้อยู่ในสถานะ {{ formatStatus(report.status) }} ไม่สามารถเพิ่มหลักฐานได้แล้ว
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

const handleFileChange = (event, reportId) => {
  const files = Array.from(event.target.files);
  const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB

  errorMessage.value = ''; // ล้าง error ก่อน

  // ตรวจสอบว่ามีไฟล์หรือไม่
  if (files.length === 0) {
    selectedFiles.value = [];
    return;
  }

  // ตรวจสอบขนาดไฟล์
  for (const file of files) {
    if (file.size > MAX_FILE_SIZE) {
      errorMessage.value = `❌ ไฟล์ "${file.name}" มีขนาด ${(file.size / (1024 * 1024)).toFixed(2)}MB ซึ่งใหญ่เกิน 10MB`;
      event.target.value = '';
      selectedFiles.value = [];
      return;
    }
  }

  // ตรวจสอบจำนวนแต่ละประเภท
  const imageFiles = files.filter(f => f.type.startsWith('image'));
  const videoFiles = files.filter(f => f.type.startsWith('video'));

  if (imageFiles.length > 3) {
    errorMessage.value = `❌ คุณเลือกรูปภาพ ${imageFiles.length} ไฟล์ ซึ่งเกินกำหนด (สูงสุด 3 ไฟล์)`;
    event.target.value = '';
    selectedFiles.value = [];
    return;
  }

  if (videoFiles.length > 3) {
    errorMessage.value = `❌ คุณเลือกวิดีโอ ${videoFiles.length} ไฟล์ ซึ่งเกินกำหนด (สูงสุด 3 ไฟล์)`;
    event.target.value = '';
    selectedFiles.value = [];
    return;
  }

  // ผ่านการตรวจสอบแล้ว
  selectedFiles.value = files;
  errorMessage.value = '';
};

const uploadToCloudinary = async (file) => {
  const config = useRuntimeConfig();
  const formData = new FormData();
  formData.append("file", file);
  formData.append("upload_preset", config.public.cloudinaryUploadPreset);

  const resourceType = file.type.startsWith('video') ? 'video' : 'image';

  const response = await fetch(
    `https://api.cloudinary.com/v1_1/${config.public.cloudinaryCloudName}/${resourceType}/upload`,
    {
      method: "POST",
      body: formData,
    },
  );

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    console.error('Cloudinary error:', errorData);
    throw new Error(errorData.error?.message || "อัปโหลด Cloudinary ไม่สำเร็จ");
  }

  return response.json();
};

const getPreviewUrl = (file) => {
  if (typeof window !== 'undefined' && window.URL && file) {
    return window.URL.createObjectURL(file);
  }
  return '';
};

const uploadEvidence = async (reportId) => {
  try {
    const token = useCookie("token").value;
    if (!token || !selectedFiles.value.length) return;

    const targetReport = allReportCases.value.find((r) => r.id === reportId);
    if (!targetReport) return;

    if (!canAddEvidence(targetReport.status)) {
      errorMessage.value = "ไม่สามารถเพิ่มหลักฐานในสถานะนี้ได้";
      return;
    }

    uploadingReportId.value = reportId;
    errorMessage.value = '';

    const newEvidences = [];

    // อัปโหลดไฟล์ทีละไฟล์
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

    // บันทึกหลักฐานไปที่ backend
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
      const errorData = await response.json();
      throw new Error(errorData.message || "บันทึกหลักฐานไม่สำเร็จ");
    }

    // อัปเดต UI
    targetReport.evidences = [
      ...(targetReport.evidences || []),
      ...newEvidences,
    ];

    // ล้างไฟล์และแสดงข้อความสำเร็จ
    selectedFiles.value = [];
    const fileInput = document.getElementById(`file-${reportId}`);
    if (fileInput) fileInput.value = '';
    
    // แสดงข้อความสำเร็จ
    const successDiv = document.createElement('div');
    successDiv.className = 'fixed top-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg z-50';
    successDiv.textContent = '✓ อัปโหลดหลักฐานสำเร็จ';
    document.body.appendChild(successDiv);
    
    setTimeout(() => {
      successDiv.remove();
    }, 3000);

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
