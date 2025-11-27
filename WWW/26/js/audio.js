// Link click audio system - plays middle C then G above (flute tone, 1/8 notes)

let audioContext = null;

// Initialize audio context on first user interaction
function initAudio() {
    if (audioContext) return;
    
    try {
        audioContext = new (window.AudioContext || window.webkitAudioContext)();
    } catch (e) {
        console.warn('Web Audio API not supported:', e);
    }
}

// Play a note (frequency in Hz, duration in seconds)
function playNote(frequency, duration, startTime = 0) {
    if (!audioContext) return;
    
    const oscillator = audioContext.createOscillator();
    const gainNode = audioContext.createGain();
    
    // Flute-like tone: sine wave with slight vibrato
    oscillator.type = 'sine';
    oscillator.frequency.setValueAtTime(frequency, audioContext.currentTime + startTime);
    
    // Add subtle vibrato (frequency modulation)
    const vibrato = audioContext.createOscillator();
    const vibratoGain = audioContext.createGain();
    vibrato.type = 'sine';
    vibrato.frequency.value = 5; // 5 Hz vibrato
    vibratoGain.gain.value = 2; // 2 Hz modulation depth
    vibrato.connect(vibratoGain);
    vibratoGain.connect(oscillator.frequency);
    
    // Envelope: quick attack, gentle release
    const now = audioContext.currentTime + startTime;
    gainNode.gain.setValueAtTime(0, now);
    gainNode.gain.linearRampToValueAtTime(0.3, now + 0.01); // Quick attack
    gainNode.gain.linearRampToValueAtTime(0.3, now + duration - 0.02);
    gainNode.gain.linearRampToValueAtTime(0, now + duration); // Gentle release
    
    oscillator.connect(gainNode);
    gainNode.connect(audioContext.destination);
    
    vibrato.start(now);
    oscillator.start(now);
    oscillator.stop(now + duration);
    vibrato.stop(now + duration);
}

// Play link click sound: middle C then G above (1/8 notes)
// Assuming 120 BPM: 1/8 note = 0.25 seconds
function playLinkSound() {
    if (!audioContext) {
        initAudio();
        if (!audioContext) return;
    }
    
    // Resume audio context if suspended (required by some browsers)
    if (audioContext.state === 'suspended') {
        audioContext.resume().then(() => {
            playNotes();
        });
        return;
    }
    
    playNotes();
    
    function playNotes() {
        const eighthNote = 0.25; // 1/8 note duration at 120 BPM
        const middleC = 261.63; // C4
        const gAbove = 392.00; // G4
        
        playNote(middleC, eighthNote, 0);
        playNote(gAbove, eighthNote, eighthNote);
    }
}

// Attach click handlers to all links
document.addEventListener('DOMContentLoaded', function() {
    // Initialize audio on first user interaction
    const initOnInteraction = function() {
        initAudio();
        document.removeEventListener('click', initOnInteraction);
        document.removeEventListener('touchstart', initOnInteraction);
    };
    
    document.addEventListener('click', initOnInteraction);
    document.addEventListener('touchstart', initOnInteraction);
    
    // Add click handlers to all links
    const links = document.querySelectorAll('a[href]');
    links.forEach(link => {
        link.addEventListener('click', function(e) {
            // Don't play sound for anchor links or special protocols
            const href = link.getAttribute('href');
            if (href && (href.startsWith('#') || href.startsWith('javascript:') || href.startsWith('mailto:'))) {
                return;
            }
            playLinkSound();
        });
    });
});

