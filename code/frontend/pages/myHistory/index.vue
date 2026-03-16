// myHistory/index.vue

<template>
  <div>
    <div class="px-4 py-8 mx-auto max-w-7xl sm:px-6 lg:px-8">
      <!-- HEADER -->
      <div class="mb-8">
        <h2 class="text-2xl font-bold text-gray-900">ประวัติการรายงานของฉัน</h2>
        <p class="mt-2 text-gray-600">ดูรายงานทั้งหมดของการเดินทางแต่ละทริป</p>
      </div>

      <!-- SEARCH SECTION -->
      <div
        class="p-6 mb-8 bg-white border border-gray-300 rounded-lg shadow-md"
      >
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
              placeholder="ค้นหาจากคำอธิบาย..."
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
              <option value="PENDING">รอการตรวจสอบ</option>
              <option value="UNDER_REVIEW">กำลังพิจารณา</option>
              <option value="RESOLVED">แก้ไขเรียบร้อยแล้ว</option>
              <option value="REJECTED">ปฏิเสธคำร้อง</option>
            </select>
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

      <!-- RESULT SECTION - TRIP CARDS -->
      <div class="bg-white border border-gray-300 rounded-lg shadow-md">
        <div class="p-6 border-b border-gray-300">
          <h3 class="text-lg font-semibold text-gray-900">
            การเดินทาง ({{ groupedTrips.length }} ทริป)
          </h3>
        </div>

        <div v-if="isLoading" class="p-6 text-center text-gray-500">
          กำลังโหลดข้อมูล...
        </div>

        <div v-else class="divide-y divide-gray-200">
          <div
            v-if="groupedTrips.length === 0"
            class="p-6 text-center text-gray-500"
          >
            ยังไม่มีประวัติการรายงาน
          </div>

          <!-- TRIP CARD -->
          <div
            v-for="tripGroup in groupedTrips"
            :key="tripGroup.routeId"
            class="transition-all duration-300"
          >
            <!-- TRIP HEADER -->
            <div
              class="p-6 cursor-pointer trip-card hover:bg-gray-50 transition-colors"
            >
              <div class="space-y-4">
                <!-- ROUTE TITLE -->
                <div>
                  <h4 class="text-xl font-bold text-gray-900">
                    {{ getLocationName(tripGroup.startLocation) }} 
                    <span class="text-gray-400 mx-2 text-lg">→</span> 
                    {{ getLocationName(tripGroup.endLocation) }}
                  </h4>
                </div>

                <!-- TRIP METADATA -->
                <div class="grid grid-cols-2 gap-3 md:grid-cols-3 text-sm">
                  <div>
                    <p class="text-gray-600 font-medium">วันเดินทาง</p>
                    <p class="text-gray-900 font-semibold">{{ formatTripDate(tripGroup.departureTime) }}</p>
                  </div>
                  <div>
                    <p class="text-gray-600 font-medium">รหัสทริป</p>
                    <p class="text-gray-900 font-semibold text-xs break-all">{{ tripGroup.routeId }}</p>
                  </div>
                  <div>
                    <p class="text-gray-600 font-medium">รายงาน</p>
                    <p class="text-gray-900 font-semibold">{{ tripGroup.reports.length }} รายงาน</p>
                  </div>
                </div>

                <!-- EXPAND BUTTON -->
                <div class="flex justify-end pt-2">
                  <button
                    @click="toggleTripSelection(tripGroup.routeId)"
                    class="inline-flex items-center gap-2 text-blue-600 font-medium hover:text-blue-700 transition"
                  >
                    {{ selectedTripId === tripGroup.routeId ? '▼' : '▶' }} {{ selectedTripId === tripGroup.routeId ? 'ปิด' : 'ดู' }} รายละเอียด
                  </button>
                </div>
              </div>
            </div>

            <!-- REPORTS DETAIL -->
            <div
              v-if="selectedTripId === tripGroup.routeId"
              class="border-t border-gray-200 bg-gray-50 divide-y divide-gray-200"
            >
              <!-- REPORT ITEMS -->
              <div
                v-for="report in tripGroup.reports"
                :key="report.id"
                class="p-6 transition-all duration-200 hover:bg-gray-100"
              >
                <div class="flex items-start justify-between gap-4 mb-4">
                  <div>
                    <h5 class="font-bold text-2xl text-gray-900">
                      {{ formatCategory(report.category) }}
                    </h5>
                    <p class="text-sm text-gray-600 mt-1 font-medium">
                      ผู้ถูกรายงาน: {{ report.reportedUser?.firstName }} {{ report.reportedUser?.lastName }}
                    </p>
                  </div>
                  <span :class="statusClass(report.status)" class="flex-shrink-0 px-4 py-2 text-sm font-bold whitespace-nowrap">
                    {{ formatStatus(report.status) }}
                  </span>
                </div>

                <div class="space-y-3 pb-4 border-b border-gray-200 mb-4">
                  <div class="grid grid-cols-2 md:grid-cols-3 gap-3 text-sm">
                    <div>
                      <p class="text-gray-600 font-medium">วันที่รายงาน</p>
                      <p class="text-gray-900">{{ formatDate(report.createdAt) }}</p>
                    </div>
                    <div>
                      <p class="text-gray-600 font-medium">รหัสรายงาน</p>
                      <p class="text-gray-900 text-xs break-all">{{ report.id }}</p>
                    </div>
                    <div>
                      <p class="text-gray-600 font-medium">หลักฐาน</p>
                      <p class="text-gray-900 font-semibold">{{ report.evidences?.length || 0 }} ไฟล์</p>
                    </div>
                  </div>
                </div>

                  <!-- REPORT DETAILS -->
                  <div class="mt-4 pt-4 border-t-2 border-gray-200 space-y-4">
                  <!-- DESCRIPTION SECTION -->
                  <div class="bg-gradient-to-r from-blue-50 to-cyan-50 p-4 rounded-lg border border-blue-200">
                    <h6 class="font-semibold text-gray-900 mb-2">รายละเอียด</h6>
                    <p class="text-gray-700 text-sm leading-relaxed whitespace-pre-line">
                      {{ report.description || 'ไม่มีรายละเอียด' }}
                    </p>
                  </div>

                  <!-- EVIDENCE SECTION -->
                  <div class="space-y-3">
                    <h6 class="font-semibold text-gray-900">
                      หลักฐาน ({{ report.evidences?.length || 0 }})
                    </h6>

                    <!-- UPLOADED EVIDENCE DISPLAY -->
                    <div v-if="report.evidences?.length > 0" class="space-y-4">
                      <!-- EVIDENCE GRID (4 per page) -->
                      <div class="grid grid-cols-2 gap-3">
                      <div
                        v-for="(evidence, idx) in getEvidencePage(report.id)"
                        :key="idx"
                        class="relative bg-white rounded-lg overflow-hidden border border-gray-300 hover:border-blue-400 transition-colors shadow-sm hover:shadow-md"
                      >
                        <!-- THUMBNAIL -->
                        <div class="aspect-video bg-gray-200 flex items-center justify-center relative group">
                          <template v-if="evidence.type === 'IMAGE'">
                            <img :src="evidence.url" :alt="`Evidence ${idx + 1}`" class="w-full h-full object-cover" />
                          </template>
                          <template v-else-if="evidence.type === 'VIDEO'">
                            <video :src="evidence.url" class="w-full h-full object-cover" />
                            <div class="absolute inset-0 flex items-center justify-center bg-black/30 group-hover:bg-black/40 transition-colors">
                              <span class="text-white text-2xl font-bold">เล่น</span>
                            </div>
                          </template>
                          <template v-else>
                            <div class="flex flex-col items-center justify-center w-full h-full bg-red-50">
                              <div class="text-4xl font-bold text-red-600 mb-2">PDF</div>
                              <p class="text-xs text-gray-600 text-center px-2 line-clamp-2">{{ evidence.fileName }}</p>
                            </div>
                          </template>


                        </div>

                        <!-- FILE INFO -->
                        <div class="p-3 bg-white border-t border-gray-200">
                          <p class="text-xs font-semibold text-gray-800 truncate mb-1">{{ evidence.fileName }}</p>
                          <div class="flex justify-between items-start mb-2">
                            <p class="text-xs text-gray-500">{{ (evidence.fileSize / 1024).toFixed(1) }} KB</p>
                            <p class="text-xs text-blue-600 font-medium">{{ formatDateTime(evidence.createdAt) }}</p>
                          </div>
                          <p v-if="evidence.description" class="text-xs text-gray-700 italic border-t pt-2 text-gray-600">
                            {{ evidence.description }}
                          </p>
                        </div>
                      </div>
                      </div>

                      <!-- PAGINATION -->
                      <div v-if="getTotalEvidencePages(report.id) > 1" class="flex items-center justify-between">
                        <button
                          @click="prevEvidencePage(report.id)"
                          :disabled="(evidencePage[report.id] || 1) === 1"
                          class="px-3 py-1 text-sm font-medium text-white bg-blue-600 rounded disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          ← ก่อนหน้า
                        </button>
                        <span class="text-sm text-gray-600">
                          หน้า {{ evidencePage[report.id] || 1 }} / {{ getTotalEvidencePages(report.id) }}
                        </span>
                        <button
                          @click="nextEvidencePage(report.id)"
                          :disabled="(evidencePage[report.id] || 1) === getTotalEvidencePages(report.id)"
                          class="px-3 py-1 text-sm font-medium text-white bg-blue-600 rounded disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          ถัดไป →
                        </button>
                      </div>
                    </div>

                    <div v-else class="text-center py-6 bg-gray-50 rounded-lg border border-dashed border-gray-300">
                      <p class="text-sm text-gray-500">ยังไม่มีหลักฐาน</p>
                    </div>
                  </div>

                  <!-- ADD EVIDENCE SECTION -->
                  <div v-if="canAddEvidence(report.status)" class="p-4 bg-gradient-to-r from-blue-50 to-cyan-50 rounded-lg border-2 border-blue-200">
                    <h6 class="font-semibold text-gray-900 mb-3">เพิ่มหลักฐานเพิ่มเติม</h6>

                    <!-- ERROR MESSAGE -->
                    <div v-if="errorMessage" class="p-3 mb-3 text-sm text-red-700 bg-red-100 border border-red-300 rounded-md">
                      ข้อผิดพลาด: {{ errorMessage }}
                    </div>

                    <!-- PENDING EVIDENCES PREVIEW (before upload) -->
                    <div v-if="pendingEvidences[report.id]?.length > 0" class="mb-4">
                      <h6 class="text-sm font-semibold text-gray-900 mb-2">ตัวอย่างภาพ ({{ pendingEvidences[report.id].length }}/3)</h6>
                      <div class="grid grid-cols-3 gap-2">
                        <div v-for="(file, idx) in pendingEvidences[report.id]" :key="idx" class="relative group">
                          <div class="aspect-square bg-gray-200 rounded-lg overflow-hidden flex items-center justify-center">
                            <template v-if="file.type?.startsWith('image')">
                              <img :src="getPreviewUrl(file)" :alt="`Preview ${idx + 1}`" class="w-full h-full object-cover" />
                            </template>
                            <template v-else>
                              <div class="text-center">
                                <div class="text-gray-500 text-xs">{{ file.name.split('.').pop() }}</div>
                              </div>
                            </template>
                          </div>
                          <button
                            @click="removePendingEvidence(report.id, idx)"
                            class="absolute top-1 right-1 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity text-xs hover:bg-red-600"
                          >
                            ×
                          </button>
                        </div>
                      </div>
                    </div>

                    <!-- FILE INPUT & UPLOAD BUTTON -->
                    <div class="flex gap-2">
                      <input
                        type="file"
                        multiple
                        @change="(e) => handleAddPendingEvidence(report.id, e)"
                        accept="image/*,video/*,.pdf,.doc,.docx"
                        class="flex-1 px-3 py-2 text-sm file:px-3 file:py-1 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-blue-600 file:text-white cursor-pointer border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                      />
                      <button
                        @click="uploadEvidence(report.id)"
                        :disabled="!pendingEvidences[report.id]?.length || uploadingReportId === report.id"
                        class="px-5 py-2 text-sm font-semibold text-white transition-all bg-gradient-to-r from-blue-600 to-blue-700 rounded-md hover:shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        {{ uploadingReportId === report.id ? 'กำลังอัปโหลด...' : 'อัปโหลด' }}
                      </button>
                    </div>

                    <p class="mt-2 text-xs text-gray-600">
                      รองรับ: รูป, วิดีโอ, PDF (สูงสุด 10MB) | อัปโหลดได้สูงสุด 3 ไฟล์ต่อครั้ง
                    </p>
                  </div>

                  <!-- CLOSED STATUS -->
                  <div v-else class="p-4 bg-gray-50 rounded-lg border border-gray-300">
                    <p class="text-sm text-gray-600">
                      เคสนี้อยู่ในสถานะ <span class="font-semibold">{{ formatStatus(report.status) }}</span> ไม่สามารถเพิ่มหลักฐานได้แล้ว
                    </p>
                  </div>
                </div>
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
const selectedTripId = ref(null);
const selectedReportId = ref(null);
const isLoading = ref(false);
const errorMessage = ref("");
const uploadingReportId = ref(null);
const selectedEvidenceFile = ref({});
const evidenceNotes = ref({});
const pendingEvidences = ref({}); // ไฟล์ที่ยังไม่ได้อัปโหลด
const evidencePage = ref({}); // Pagination สำหรับหลักฐาน

// Group reports by trip
const groupedTrips = computed(() => {
  let filtered = [...allReportCases.value];

  // Apply filters
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

  // Group by routeId
  const grouped = {};
  filtered.forEach((report) => {
    const routeId = report.route?.id;
    if (!routeId) return;

    if (!grouped[routeId]) {
      grouped[routeId] = {
        routeId,
        startLocation: report.route.startLocation,
        endLocation: report.route.endLocation,
        departureTime: report.route.departureTime,
        reports: [],
        statusCount: { PENDING: 0, UNDER_REVIEW: 0, RESOLVED: 0, REJECTED: 0 }
      };
    }

    grouped[routeId].reports.push(report);
    grouped[routeId].statusCount[report.status] = (grouped[routeId].statusCount[report.status] || 0) + 1;
  });

  return Object.values(grouped).sort((a, b) => 
    new Date(b.departureTime) - new Date(a.departureTime)
  );
});

const searchForm = ref({
  keyword: "",
  category: "",
  status: "",
});

const toggleTripSelection = (routeId) => {
  selectedTripId.value = selectedTripId.value === routeId ? null : routeId;
  selectedReportId.value = null; // Reset report details when toggling trip
};

const toggleReportDetails = (reportId) => {
  selectedReportId.value = selectedReportId.value === reportId ? null : reportId;
};

const getLocationName = (location) => {
  if (!location) return '-';
  
  // If location is a JSON object with name or address field
  if (typeof location === 'object') {
    return location.name || location.address || location.label || '-';
  }
  
  // If it's a string
  return String(location);
};

const formatTripDate = (departureTime) => {
  if (!departureTime) return '-';
  
  const date = new Date(departureTime);
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const year = date.getFullYear() + 543; // Buddhist Era
  const time = String(date.getHours()).padStart(2, '0') + ':' + String(date.getMinutes()).padStart(2, '0');
  
  return `${day}/${month}/${year} เวลา ${time}`;
};

const canAddEvidence = (status) => {
  return !["RESOLVED", "REJECTED", "CLOSED"].includes(status);
};

const handleEvidenceSelect = (reportId, event) => {
  const files = Array.from(event.target.files);
  const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB

  errorMessage.value = ''; // ล้าง error ก่อน

  if (files.length === 0) return;

  // ตรวจสอบขนาดไฟล์แต่ละตัว
  for (const file of files) {
    if (file.size > MAX_FILE_SIZE) {
      errorMessage.value = `ไฟล์ "${file.name}" มีขนาด ${(file.size / (1024 * 1024)).toFixed(2)}MB ซึ่งใหญ่เกิน 10MB`;
      event.target.value = '';
      return;
    }
  }

  // ผ่านการตรวจสอบแล้ว
  selectedEvidenceFile.value[reportId] = files[0];
  errorMessage.value = '';
};

const handleAddPendingEvidence = (reportId, event) => {
  const files = Array.from(event.target.files);
  const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
  const MAX_FILES = 3;

  errorMessage.value = '';

  if (files.length === 0) return;

  // ตรวจสอบจำนวนไฟล์ (รวมกับไฟล์ที่มีอยู่)
  const existingCount = pendingEvidences.value[reportId]?.length || 0;
  if (existingCount + files.length > MAX_FILES) {
    errorMessage.value = `สามารถอัปโหลดได้สูงสุด ${MAX_FILES} ไฟล์ต่อครั้ง (มีอยู่แล้ว ${existingCount} ไฟล์)`;
    event.target.value = '';
    return;
  }

  // ตรวจสอบขนาดไฟล์
  for (const file of files) {
    if (file.size > MAX_FILE_SIZE) {
      errorMessage.value = `ไฟล์ "${file.name}" มีขนาด ${(file.size / (1024 * 1024)).toFixed(2)}MB ซึ่งใหญ่เกิน 10MB`;
      event.target.value = '';
      return;
    }
  }

  // เพิ่มลงใน pending list
  if (!pendingEvidences.value[reportId]) {
    pendingEvidences.value[reportId] = [];
  }

  pendingEvidences.value[reportId].push(...files);
  event.target.value = '';
};

const removePendingEvidence = (reportId, idx) => {
  if (pendingEvidences.value[reportId]) {
    pendingEvidences.value[reportId].splice(idx, 1);
  }
};

const getEvidencePage = (reportId) => {
  const report = allReportCases.value.find((r) => r.id === reportId);
  if (!report?.evidences) return [];

  const page = evidencePage.value[reportId] || 1;
  const pageSize = 4;
  const start = (page - 1) * pageSize;
  const end = start + pageSize;

  return report.evidences.slice(start, end);
};

const getTotalEvidencePages = (reportId) => {
  const report = allReportCases.value.find((r) => r.id === reportId);
  if (!report?.evidences) return 0;

  const pageSize = 4;
  return Math.ceil(report.evidences.length / pageSize);
};

const prevEvidencePage = (reportId) => {
  const currentPage = evidencePage.value[reportId] || 1;
  if (currentPage > 1) {
    evidencePage.value[reportId] = currentPage - 1;
  }
};

const nextEvidencePage = (reportId) => {
  const currentPage = evidencePage.value[reportId] || 1;
  const totalPages = getTotalEvidencePages(reportId);
  if (currentPage < totalPages) {
    evidencePage.value[reportId] = currentPage + 1;
  }
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
    const config = useRuntimeConfig();
    const baseUrl = config.public.apiBase;
    
    const files = pendingEvidences.value[reportId];

    if (!token || !files?.length) return;

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
    for (const file of files) {
      const cloudinaryData = await uploadToCloudinary(file);

      newEvidences.push({
        type: file.type.startsWith("video") ? "VIDEO" : "IMAGE",
        url: cloudinaryData.secure_url,
        fileName: file.name,
        mimeType: file.type,
        fileSize: file.size,
        description: "",
      });
    }

    // บันทึกหลักฐานไปที่ backend
    const response = await fetch(
      `${baseUrl}/reports/${reportId}/evidence`,
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
    
    // ล้างข้อมูล
    pendingEvidences.value[reportId] = [];
    evidenceNotes.value[reportId] = '';
    evidencePage.value[reportId] = 1;
    
    // แสดงข้อความสำเร็จ
    const successDiv = document.createElement('div');
    successDiv.className = 'fixed top-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg z-50';
    successDiv.textContent = `อัปโหลดหลักฐาน ${files.length} ไฟล์สำเร็จ`;
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
    const config = useRuntimeConfig();
    const baseUrl = config.public.apiBase;
    
    if (!token) {
      router.push("/login");
      return;
    }

    isLoading.value = true;
    errorMessage.value = "";
    selectedTripId.value = null;
    selectedReportId.value = null;

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
      `${baseUrl}reports/my?${query.toString()}`,
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

const formatDateTime = (date) => {
  if (!date) return "-";
  const d = new Date(date);
  const dateStr = d.toLocaleDateString("th-TH", {
    month: "short",
    day: "numeric",
  });
  const timeStr = String(d.getHours()).padStart(2, '0') + ':' + String(d.getMinutes()).padStart(2, '0');
  return `${dateStr} ${timeStr}`;
};

const statusClass = (status) => {
  const map = {
    PENDING:
      "px-4 py-2 text-sm font-bold bg-blue-200 text-blue-900 rounded-lg",
    UNDER_REVIEW:
      "px-4 py-2 text-sm font-bold bg-yellow-200 text-yellow-900 rounded-lg",
    RESOLVED:
      "px-4 py-2 text-sm font-bold bg-green-200 text-green-900 rounded-lg",
    REJECTED:
      "px-4 py-2 text-sm font-bold bg-red-200 text-red-900 rounded-lg",
  };
  return map[status] || "";
};

const formatStatus = (status) => {
  const map = {
    PENDING: "รอการตรวจสอบ",
    UNDER_REVIEW: "กำลังพิจารณา",
    RESOLVED: "แก้ไขเรียบร้อยแล้ว",
    REJECTED: "ปฏิเสธคำร้อง",
  };
  return map[status] || status;
};

const handleSearch = async () => {
  selectedTripId.value = null;
  selectedReportId.value = null;
  // The groupedTrips computed will automatically update
};

const handleReset = () => {
  searchForm.value = {
    keyword: "",
    category: "",
    status: "",
  };

  selectedTripId.value = null;
  selectedReportId.value = null;
};

const deleteEvidence = async (reportId, pageIdx) => {
  try {
    if (!confirm('คุณต้องการลบหลักฐานนี้ใช่หรือไม่?')) return;

    const token = useCookie("token").value;
    const config = useRuntimeConfig();
    const baseUrl = config.public.apiBase;

    const targetReport = allReportCases.value.find((r) => r.id === reportId);
    if (!targetReport || !targetReport.evidences) return;

    // คำนวณ index ที่แท้จริงจากการ paginate
    const page = evidencePage.value[reportId] || 1;
    const pageSize = 4;
    const actualIdx = (page - 1) * pageSize + pageIdx;

    const evidence = targetReport.evidences[actualIdx];
    if (!evidence) return;

    // ลบจาก backend
    const response = await fetch(
      `${baseUrl}/reports/${reportId}/evidence`,
      {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ evidenceId: evidence.id }),
      },
    );

    if (!response.ok) {
      throw new Error("ลบหลักฐานไม่สำเร็จ");
    }

    // ลบจาก UI
    targetReport.evidences.splice(actualIdx, 1);

    // ปรับ page ถ้าหน้าปัจจุบันว่างเปล่า
    const newTotalPages = getTotalEvidencePages(reportId);
    if (page > newTotalPages && page > 1) {
      evidencePage.value[reportId] = page - 1;
    }

    // แสดงข้อความสำเร็จ
    const successDiv = document.createElement('div');
    successDiv.className = 'fixed top-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg z-50';
      successDiv.textContent = 'ลบหลักฐานสำเร็จ';
    document.body.appendChild(successDiv);
    
    setTimeout(() => {
      successDiv.remove();
    }, 3000);
  } catch (err) {
    errorMessage.value = err.message;
  }
};

onMounted(() => {
  fetchReports();
});
</script>
