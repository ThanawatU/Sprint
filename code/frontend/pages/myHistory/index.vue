<template>
  <div>
    <div class="px-4 py-8 mx-auto max-w-7xl sm:px-6 lg:px-8">
      <!-- SEARCH SECTION -->
      <div
        class="p-6 mb-8 bg-white border border-gray-300 rounded-lg shadow-md"
      >
        <h2 class="mb-6 text-xl font-semibold text-gray-900">
          ประวัติการรีพอร์ตของฉัน
        </h2>

        <form
          @submit.prevent="handleSearch"
          class="grid grid-cols-1 gap-4 md:grid-cols-4"
        >
          <input
            v-model="searchForm.keyword"
            type="text"
            placeholder="ค้นหาคำอธิบาย..."
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
          />

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

          <select
            v-model="searchForm.status"
            class="w-full px-3 py-2 border border-gray-300 rounded-md"
          >
            <option value="">ทุกสถานะ</option>
            <option value="FILED">FILED</option>
            <option value="UNDER_REVIEW">UNDER_REVIEW</option>
            <option value="INVESTIGATING">INVESTIGATING</option>
            <option value="RESOLVED">RESOLVED</option>
            <option value="REJECTED">REJECTED</option>
            <option value="CLOSED">CLOSED</option>
          </select>

          <button
            type="submit"
            class="px-5 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700"
          >
            ค้นหา
          </button>
        </form>
      </div>

      <!-- RESULT SECTION -->
      <div class="bg-white border border-gray-300 rounded-lg shadow-md">
        <div class="p-6 border-b border-gray-300">
          <h3 class="text-lg font-semibold text-gray-900">
            รายการรีพอร์ต ({{ reportCases.length }} รายการ)
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
            ยังไม่มีประวัติการรีพอร์ต
          </div>

          <!-- CARD -->
          <div
            v-for="report in reportCases"
            :key="report.id"
            class="p-6 transition-all duration-300 cursor-pointer hover:shadow-lg"
            @click="toggleDetails(report)"
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

              <!-- STATUS BADGE -->
              <span :class="statusClass(report.status)">
                {{ report.status }}
              </span>
            </div>

            <!-- DETAIL -->
            <div
              v-if="selectedReport?.id === report.id"
              class="pt-4 mt-4 border-t border-gray-300"
            >
              <h5 class="mb-2 font-medium text-gray-900">
                รายละเอียดการรีพอร์ต
              </h5>

              <p
                class="p-3 text-sm text-gray-700 border border-gray-300 rounded-md bg-gray-50"
              >
                {{ report.description }}
              </p>

              <!-- EVIDENCE -->
              <div v-if="report.evidences?.length" class="mt-4">
                <h5 class="mb-2 font-medium text-gray-900">หลักฐานที่แนบ</h5>

                <div class="grid grid-cols-2 gap-3 md:grid-cols-3">
                  <div v-for="evidence in report.evidences" :key="evidence.id">
                    <img
                      v-if="evidence.type === 'IMAGE'"
                      :src="evidence.url"
                      class="object-cover w-full border border-gray-300 rounded-lg aspect-video"
                    />

                    <video
                      v-else-if="evidence.type === 'VIDEO'"
                      controls
                      class="w-full border border-gray-300 rounded-lg aspect-video"
                    >
                      <source :src="evidence.url" />
                    </video>

                    <a
                      v-else
                      :href="evidence.url"
                      target="_blank"
                      class="text-sm text-blue-600 underline"
                    >
                      ดาวน์โหลดไฟล์
                    </a>
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
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";

const reportCases = ref([]);
const selectedReport = ref(null);
const isLoading = ref(false);

const searchForm = ref({
  keyword: "",
  category: "",
  status: "",
});

const fetchReports = async () => {
  try {
    isLoading.value = true;
    const data = await $fetch("/api/report-cases/my", {
      params: searchForm.value,
    });

    reportCases.value = data;
    
  } catch (err) {
    console.error(err);
  } finally {
    isLoading.value = false;
  }
};

const handleSearch = () => {
  fetchReports();
};

const toggleDetails = (report) => {
  selectedReport.value = selectedReport.value?.id === report.id ? null : report;
};

const formatDate = (date) => {
  return new Date(date).toLocaleString("th-TH");
};

const formatCategory = (cat) => {
  const map = {
    DANGEROUS_DRIVING: "ขับรถอันตราย",
    AGGRESSIVE_BEHAVIOR: "พฤติกรรมก้าวร้าว",
    HARASSMENT: "คุกคาม",
    NO_SHOW: "ไม่มาตามนัด",
    FRAUD_OR_SCAM: "ฉ้อโกง",
    OTHER: "อื่น ๆ",
  };
  return map[cat] || cat;
};

const statusClass = (status) => {
  return [
    "px-3 py-1 rounded-full text-xs font-medium",
    status === "FILED"
      ? "bg-gray-100 text-gray-800"
      : status === "UNDER_REVIEW"
        ? "bg-yellow-100 text-yellow-800"
        : status === "INVESTIGATING"
          ? "bg-blue-100 text-blue-800"
          : status === "RESOLVED"
            ? "bg-green-100 text-green-800"
            : status === "REJECTED"
              ? "bg-red-100 text-red-800"
              : "bg-gray-200 text-gray-700",
  ];
};

onMounted(() => {
  fetchReports();
});
</script>
