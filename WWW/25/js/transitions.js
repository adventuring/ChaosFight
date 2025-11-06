// Page transition system - elements fly in from off-screen (0.5s max)

function initTransitions() {
    // Add transition-in class to all box elements on page load
    const boxes = document.querySelectorAll('.box, .character-card, .download-card, nav, .hero');
    
    boxes.forEach((box, index) => {
        // Stagger animations slightly
        const delay = index * 0.05;
        box.style.opacity = '0';
        box.style.animationDelay = `${delay}s`;
        
        // Random animation type for variety
        const animTypes = ['slide', 'fade', 'scale', 'spin'];
        const animType = animTypes[index % animTypes.length];
        
        box.classList.add('transition-in');
        box.setAttribute('data-anim-type', animType);
    });
    
    // Handle page exit transitions (optional - can be disabled if causing issues)
    // Note: This prevents default navigation, so use with caution
    // For now, we'll let normal navigation work and just animate on page load
}

// Enhanced CSS animations for different transition types
const style = document.createElement('style');
style.textContent = `
    .transition-in[data-anim-type="slide"] {
        animation: slideIn 0.5s ease-out forwards;
    }
    
    .transition-in[data-anim-type="fade"] {
        animation: fadeIn 0.5s ease-out forwards;
    }
    
    .transition-in[data-anim-type="scale"] {
        animation: scaleIn 0.5s ease-out forwards;
    }
    
    .transition-in[data-anim-type="spin"] {
        animation: spinIn 0.5s ease-out forwards;
    }
    
    @keyframes slideIn {
        from {
            opacity: 0;
            transform: translateX(-50px);
        }
        to {
            opacity: 1;
            transform: translateX(0);
        }
    }
    
    @keyframes fadeIn {
        from {
            opacity: 0;
        }
        to {
            opacity: 1;
        }
    }
    
    @keyframes scaleIn {
        from {
            opacity: 0;
            transform: scale(0.8);
        }
        to {
            opacity: 1;
            transform: scale(1);
        }
    }
    
    @keyframes spinIn {
        from {
            opacity: 0;
            transform: rotate(-10deg) scale(0.9);
        }
        to {
            opacity: 1;
            transform: rotate(0deg) scale(1);
        }
    }
    
    @keyframes flyOut {
        from {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
        to {
            opacity: 0;
            transform: translateY(-30px) scale(0.95);
        }
    }
`;
document.head.appendChild(style);

// Initialize on DOM ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initTransitions);
} else {
    initTransitions();
}

