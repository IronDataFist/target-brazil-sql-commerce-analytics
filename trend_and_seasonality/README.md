## 1. DATA PREPARATION & TIME DIMENSIONS
**orders_time_status CTE**: Centralized analysis table extracting temporal dimensions from order_purchase_timestamp:

| Column | Description | Purpose |
|--------|-------------|---------|
| `order_id` | Unique order identifier | Primary key |
| `order_year`, `order_month_num`, `order_day` | Date components | Monthly/yearly aggregation |
| `order_hour` | Hour of purchase (0-23) | Time-of-day analysis |
| `order_weekday` | Day name (Monday-Sunday) | Weekday vs weekend comparison |
| `time_of_day` | Dawn (00-06), Morning (07-12), Afternoon (13-18), Night (19-23) | Peak ordering period identification |


## 2. YEARLY ORDER VOLUME TRENDS
**Order volume demonstrated strong yearly growth** across the 3-year period (Sep 2016-Oct 2018):

| Year      | Date Range     | Orders     | % of Total |
|-----------|----------------|------------|------------|
| **2018**  | Jan 1 - Oct 17 | **54,011** | **54.3%**  |
| **2017**  | Jan 5 - Dec 31 | **45,101** | **45.4%**  |
| **2016**  | Sep 4 - Dec 23 | **329**    | **0.3%**   |
| **Total** |                | **99,441** | **100%**   |

**Key Finding**: 2018 captured **>50% of total volume** despite 9-month coverage, signaling rapid e-commerce acceleration.

## 3. MONTHLY SEASONALITY PATTERNS
**2018 established superior monthly consistency** vs 2017:
* Order analysis shows that 2018 significantly outperformed 2017, with consistently higher order volumes across most months.
* Ordering patterns in 2018 display greater consistency with fewer sharp declines.
* Increased order volumes suggest a rise in customer trust and brand credibility.

**Strategic Value**: Consistent patterns support inventory optimization despite single-purchase customer base.

## 4. TIME-OF-DAY & WEEKDAY PATTERNS
**Afternoon dominates ordering** (38.4% of total volume), establishing clear operational peak:

| Time Period   | Orders     | % of Total | 
|---------------|------------|------------|
| **Afternoon** | **38,135** | **38.4%**  |
| Night         |   28,331   |   28.5%    |
| Morning       |   27,733   |   27.9%    |
| **Dawn**      | **5,242**  | **5.3%**   |

**Weekday vs Weekend Stability**: 
- Weekdays: **76,597 orders** (136/day across 565 days)  
- Weekends: **22,847 orders** (101/day across 226 days)
- **25% weekend reduction** = Manageable demand consistency
**Operational Impact**: Rotational staffing optimized for Afternoon peaks (38K orders), minimal weekend adjustments required.

## 5. TOP CONTRIBUTING MONTHS & EVENT SPIKES
**November 2017 dominated** with **7.59% of total orders** (7,543 orders), followed by 2018 Q1/Q2 at **7.31%** and **6.1%**
**Event Analysis - Black Friday Impact**: 2017-11-24 (Black Friday): 1,176 orders;
- National Context: R$2.1-2.2B Brazilian e-commerce record ($680M USD)
- Business Impact: Elevated volume sustained 5 days (Nov 24-28)
- Cyber Monday window: Confirmed extended event-driven demand surge



