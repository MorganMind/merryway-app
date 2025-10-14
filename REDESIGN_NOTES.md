# Home Screen Redesign Implementation Notes

## Design Tokens Applied

### Colors
- **Ink (primary text)**: `#14181D`  
- **Slate (secondary)**: `#2A3037`  
- **Muted text**: `#64707D`  
- **Canvas (page bg)**: `#FAF8F3`  
- **Card surface**: `#FFFFFF` @ 96% opacity  
- **Divider**: `#E8E6E1`  
- **Accent gold**: `#C9A24A`  
- **Accent sage**: `#7BA89A`  

### Shadows
- **Level 1 (cards)**: `BoxShadow(offset: Offset(0, 8), blurRadius: 24, color: Colors.black.withOpacity(0.06))`
- **Level 2 (sticky)**: `BoxShadow(offset: Offset(0, 12), blurRadius: 32, color: Colors.black.withOpacity(0.10))`

### Radii
- **Card**: `24px`
- **Pills/chips**: `999px` (full)
- **Buttons/inputs**: `14px`

### Spacing
- Base scale: 4, 8, 12, 16, 20, 24, 32
- Page gutters: 24px mobile, 32px desktop

### Typography (Inter/system-ui)
- **Title/Lg**: 22px, weight 600 (card titles)
- **Title/Sm**: 18px, weight 600 (section headings)
- **Body**: 16px, weight 400 (descriptions)
- **Meta**: 14px, weight 500 (pills, labels)
- **Caption**: 12-13px, weight 500 (badges, helpers)
- **Button**: 16px, weight 600 (CTAs)

## Key Structural Changes

1. **Header**: Compact sticky bar with greeting + family name on left, icons on right
2. **Pod Row**: Sticky horizontal scroll directly under header
3. **Search**: Compact field under pod row  
4. **Suggestion Cards**: Simplified with:
   - Title + menu (···)
   - "Why now" line
   - Meta pills row
   - Location with pin
   - Active pod + tweak chip
   - Collapsed details (chevrons)
   - CTA row: Make it an experience (primary), Wishbook (secondary), Skip (text link)

5. **Removed**: Duplicate participant sections, large header blocks, extra borders

## Implementation Strategy

Given the 1456-line file, I'll:
1. Update the build method structure
2. Create new simplified card widget
3. Apply design tokens
4. Update state management as needed

This is a significant refactoring - estimate 2-3 hours of development time.

